import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lecture_package.dart';

import 'package:collection/collection.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/utils/exceptions/no_internet_exception.dart';
import 'package:lectary/utils/response_type.dart';
import 'package:lectary/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

/// ViewModel containing data and methods for the lecture management screen and the drawer
/// uses [ChangeNotifier] for propagating changes to UI components
class LectureViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

  // represents the loading status of fetching available lectures
  Response _availableLectureStatus = Response.completed();
  Response get availableLectureStatus => _availableLectureStatus;

  bool _availableLectureOffline = false;
  bool get availableLectureOffline => _availableLectureOffline;

  // holds all lectures that are available (persisted and remote ones)
  List<LecturePackage> _availableLectures = List();
  // holds all filtered lectures by reference from _availableLectures
  List<LecturePackage> _filteredLectures = List();
  List<LecturePackage> get availableLectures => _filteredLectures;

  // holds all persisted lectures
  List<Vocable> _currentVocables = List();
  List<Vocable> get currentVocables => _currentVocables;

  LectureViewModel({@required lectureRepository})
      : _lectureRepository = lectureRepository;


  Stream<List<LecturePackage>> loadLocalLecturesAsStream() {
    return _lectureRepository.watchAllLectures().map((list) => _groupLecturesByPack(list));
  }

  /// Groups a lecture list by the lecture pack
  /// returns a [List] of [LecturePackage]
  List<LecturePackage> _groupLecturesByPack(List<Lecture> lectureList) {
    final lecturesByPack = groupBy(lectureList, (lecture) => (lecture as Lecture).pack);
    List<LecturePackage> packList = List();
    lecturesByPack.forEach((key, value) => packList.add(LecturePackage(key, value)));
    return packList;
  }

  /// Loads all available lectures that can be used
  /// Returns a [Future] and indicates its loading status via a separate variable [_availableLectureStatus] of type [Response]
  Future<void> loadLectures() async {
    _availableLectureStatus = Response.loading("fetching lectures from server");
    notifyListeners();

    try {
      List<Lecture> localList = await _lectureRepository.loadLecturesLocal();
      log("loaded local lectures");

      List<Lecture> remoteList;
      List<Lecture> mergedLectureList;
      try {
        remoteList = await _lectureRepository.loadLecturesRemote();
        log("loaded remote lectures");
        _availableLectureOffline = false;
        mergedLectureList = _mergeLectureLists(remoteList, localList);
      } on NoInternetException {
        log("no internet connection");
        _availableLectureOffline = true;
        mergedLectureList = localList;
        mergedLectureList.forEach((lecture) => lecture.lectureStatus = LectureStatus.persisted);
      }

      // 1) sort lessons with SORT-meta info by SORT
      List<Lecture> lecturesWithSortMeta = mergedLectureList.where((lecture) => lecture.sort != null).toList();
      lecturesWithSortMeta.sort((l1, l2) => l1.sort.compareTo(l2.sort));
      // 2) sort lessons without SORT-meta info lexicographic by lesson
      List<Lecture> lecturesWithoutSortMeta = mergedLectureList.where((lecture) => lecture.sort == null).toList();
      lecturesWithoutSortMeta.sort((l1, l2) => l1.lesson.toLowerCase().compareTo(l2.lesson.toLowerCase()));

      // merge both sorted lists and group by lecture pack
      List<Lecture> allLectures = lecturesWithSortMeta;
      allLectures.addAll(lecturesWithoutSortMeta);
      List<LecturePackage> groupedLectureList = _groupLecturesByPack(allLectures);

      // 3) sort lexicographic by packs
      groupedLectureList.sort((p1, p2) => p1.title.toLowerCase().compareTo(p2.title.toLowerCase()));

      _availableLectures = groupedLectureList;
      // assignment by reference
      _filteredLectures = _availableLectures;

      _availableLectureStatus = Response.completed();
      notifyListeners();
    } catch(e) {
      _availableLectureStatus = Response.error(e.toString());
      notifyListeners();
    }
  }

  /// Merges the remote and local lecture list
  /// Returns a list of [Lecture] containing all locally persisted and remote available lectures with the corresponding [LectureStatus]
  List<Lecture> _mergeLectureLists(List<Lecture> remoteList, List<Lecture> localList) {
    List<Lecture> resultList = List();

    // comparing local with remote list and adding all local persisted lectures to the result list and checking if updates are available (i.e. identical lecture with never date)
    localList.forEach((local) {
      remoteList.forEach((remote) {
        if (local.pack == remote.pack && local.lesson == remote.lesson) {
          if (DateTime.parse(local.date).isBefore(DateTime.parse(remote.date))) {
            local.lectureStatus = LectureStatus.updateAvailable;
            local.fileNameUpdate = remote.fileName;
            resultList.add(local);
          } else {
            local.lectureStatus = LectureStatus.persisted;
            resultList.add(local);
          }
        }
      });
    });

    // check if any local lectures are outdated (i.e. not available remotely anymore)
    localList.forEach((e1) {
      if (remoteList.any((e2) => e1.pack == e2.pack && e1.lesson == e2.lesson) == false) {
        e1.lectureStatus = LectureStatus.removed;
        resultList.add(e1);
      }
    });

    // add all remaining and not persisted lectures available remotely
    remoteList.forEach((e1) {
      if (localList.any((e2) => e1.pack == e2.pack && e1.lesson == e2.lesson) == false) {
        e1.lectureStatus = LectureStatus.notPersisted;
        resultList.add(e1);
      }
    });

    return resultList;
  }

  /// Download and persist a lecture
  /// returns [Response] as a Future, with the corresponding [Status] set, reflecting success or failure
  Future<Response> downloadAndSaveLecture(Lecture lecture) async {
    log("downloading lecture: ${lecture.toString()}");

    // retrieve index of pack and index of lecture of the lecture-parameter to change LectureStatus
    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    // update LectureStatus and notify listeners for updating UI
    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    try {
      File lectureFile = await _lectureRepository.downloadLecture(lecture); // download lecture and save zip temporary as file
      List<Vocable> vocables = await _extractAndSaveZipFile(lectureFile); // extract zip and save content
      int newId = await _lectureRepository.insertLecture(lecture); // persist lecture and retrieve autoGenerated id
      vocables.forEach((element) => element.lectureId = newId); // set id in every vocable
      await _lectureRepository.insertVocables(vocables); // save the vocables in the database

      _availableLectures[indexPack].children[indexLecture].id = newId; // set newId in the lecture list for later usage like updating or deleting
      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.persisted;
      notifyListeners();

      return Response.completed();
    } catch(e) {
      log("downloading lecture failed: ${e.toString()}");
      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.notPersisted;
      notifyListeners();

      return Response.error(e.toString());
    }
  }


  /// Updates a lecture
  /// The lecture-update is first downloaded and extracted for validation, then the old lecture is deleted
  /// and the new lecture saved.
  /// returns [Response] as a Future, with the corresponding [Status] set, reflecting success or failure
  Future<Response> updateLecture(Lecture lecture) async {
    log("updating lecture: ${lecture.toString()}");

    // retrieve index of pack and index of lecture of the lecture-parameter to change LectureStatus
    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    // update LectureStatus and notify listeners for updating UI
    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    Lecture oldLecture = Lecture.clone(lecture);

    // updating object values for downloading and saving
    lecture.id = null;
    lecture.fileName = lecture.fileNameUpdate;
    lecture.fileNameUpdate = null;
    String newDate = Utils.extractDateFromLectureFilename(lecture.fileName);
    lecture.date = newDate;

    try {
      log("downloading new lecture: ${lecture.toString()}");
      File lectureFile = await _lectureRepository.downloadLecture(lecture); // download lecture and save zip temporary as file
      List<Vocable> vocables = await _extractAndSaveZipFile(lectureFile); // extract zip and save content

      // delete media files and database entries
      log("deleting old lecture: ${oldLecture.toString()}");
      await _deleteMediaFiles(oldLecture);
      await _lectureRepository.deleteVocablesByLectureId(oldLecture.id);
      await _lectureRepository.deleteLecture(oldLecture);

      log("saving new lecture: ${lecture.toString()}");
      int newId = await _lectureRepository.insertLecture(lecture); // persist lecture and retrieve autoGenerated id
      vocables.forEach((element) => element.lectureId = newId); // set id in every vocable
      await _lectureRepository.insertVocables(vocables); // save the vocables in the database

      _availableLectures[indexPack].children[indexLecture].id = newId; // set newId in the lecture list for later usage like updating or deleting
      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.persisted;
      notifyListeners();

      return Response.completed();
    } catch(e) {
      log("updating lecture failed: ${e.toString()}");
      // resetting object values
      lecture.id = oldLecture.id;
      lecture.fileName = oldLecture.fileName;
      lecture.fileNameUpdate = oldLecture.fileNameUpdate;
      lecture.date = oldLecture.date;

      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.updateAvailable;
      notifyListeners();

      return Response.error(e.toString());
    }
  }

  /// Deletes a lecture
  /// All database entries and files from the lecture are removed from the device.
  /// returns [Response] as a Future, with the corresponding [Status] set, reflecting success or failure
  Future<Response> deleteLecture(Lecture lecture) async {
    log("deleting lecture: ${lecture.toString()}");

    // retrieve index of pack and index of lecture of the lecture-parameter to change LectureStatus
    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    // update LectureStatus and notify listeners for updating UI
    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    try {
      // delete media files and database entries
      await _deleteMediaFiles(lecture);
      await _lectureRepository.deleteVocablesByLectureId(lecture.id);
      await _lectureRepository.deleteLecture(lecture);

      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.notPersisted;
      notifyListeners();

      return Response.completed();
    } catch(e) {
      log("deleting lecture failed: ${e.toString()}");
      return Response.error(e.toString());
    }
  }

  /// Deletes all lectures, vocables and corresponding media files
  /// returns an empty [Future]
  Future<void> deleteAllLectures() async {
    // TODO remove - only for testing purpose
    await Future.delayed(Duration(seconds: 2));
    log("querying all lectures");
    List<Lecture> lectures = await _lectureRepository.loadLecturesLocal();
    log("deleting all media files");
    await Future.forEach(lectures, (lecture) => _deleteMediaFiles(lecture));
    await _lectureRepository.deleteAllVocables();
    await _lectureRepository.deleteAllLectures();
  }

  /// Deletes media files related to the lecture
  /// Returns a [Future]
  Future<void> _deleteMediaFiles(Lecture lecture) async {
    String dir = (await getApplicationDocumentsDirectory()).path;

    final dirName = lecture.fileName.split('.')[0];
    final lectureDir = Directory(dir + '/' + dirName);
    lectureDir.deleteSync(recursive: true);
  }

  /// Extracts and saves the content of a zip-file
  /// Returns a list of [Vocable], representing all vocables of the extracted zip-file
  Future<List<Vocable>> _extractAndSaveZipFile(File zipFile) async {
    // read zip file and decode archive
    var bytes = zipFile.readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);

    // validate archive
    Utils.validateArchive(zipFile, archive);

    // get the path to the device's application directory
    String dir = (await getApplicationDocumentsDirectory()).path;

    List<Vocable> vocables = List();

    for (ArchiveFile file in archive) {
      if (!file.isFile) continue;

      // file.name holds archive name plus actual filename
      String fileName = '$dir/${file.name}';

      // extract file extension for file validation and the filename representing the vocable
      String vocable = Utils.extractFileName(file.name);
      String extension = Utils.extractFileExtension(file.name);

      // check whether media types are all valid
      MediaType mediaType = MediaType.fromString(extension);

      // save media file locally
      File outFile = File(fileName);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content);

      // construct model class
      // TODO review: save file path as content in general (not the content text directly in case of txt-file)
      String content;
      switch (mediaType) {
        case MediaType.JPG:
        case MediaType.MP4:
        case MediaType.PNG:
          content = file.name;
          break;
        case MediaType.TXT:
          content = utf8.decode(file.content);
          break;
      }
      vocables.add(Vocable(
        lectureId: null,
        vocable: vocable,
        media: content,
        mediaType: mediaType.toString(),
        vocableProgress: 0,
      ));
    }
    vocables.forEach((voc) => log(voc.toString()));

    return vocables;
  }

  /// Filters the [List] of available [Lecture] by a [String]
  /// Filters by pack and lesson of [Lecture]
  /// Creates a temporary list with the filtered elements as references to the original list elements of
  /// [_availableLectures] and assigns it by reference again to [_filteredLectures] and notifies listeners
  /// Operations on the original list [_availableLectures] will therefore also affect the corresponding elements in [_filteredLectures]
  void filterLectureList(String filter) {
    List<Lecture> tempListLectures = List();
    _availableLectures.forEach((pack) => pack.children.forEach((lecture) {
          if (lecture.pack.toLowerCase().contains(filter.toLowerCase()) ||
              lecture.lesson.toLowerCase().contains(filter.toLowerCase())) {
            tempListLectures.add(lecture);
          }
        }));
    List<LecturePackage> tempListPacks = _groupLecturesByPack(tempListLectures);
    _filteredLectures = tempListPacks;
    notifyListeners();
  }
}