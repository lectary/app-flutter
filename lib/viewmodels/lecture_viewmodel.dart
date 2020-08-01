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
import 'package:lectary/utils/exceptions/media_type_exception.dart';
import 'package:lectary/utils/response_type.dart';
import 'package:lectary/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class LectureViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

  List<LecturePackage> _availableLectures = List();
  Response _lectureListResponse = Response.completed();

  List<LecturePackage> get availableLectures => _availableLectures;
  Response get lectureListResponse => _lectureListResponse;

  List<Vocable> _currentVocables = List();
  List<Vocable> get currentVocables => _currentVocables;

  LectureViewModel({@required lectureRepository})
      : _lectureRepository = lectureRepository;


  Stream<List<LecturePackage>> loadLocalLecturesAsStream() {
    return _lectureRepository.watchAllLectures().map((list) => _groupLecturesByPack(list));
  }

  List<LecturePackage> _groupLecturesByPack(List<Lecture> lectureList) {
    final lecturesByPack = groupBy(lectureList, (lecture) => (lecture as Lecture).pack);
    List<LecturePackage> packList = List();
    lecturesByPack.forEach((key, value) => packList.add(LecturePackage(key, value)));
    return packList;
  }

  Future<void> loadLectures() async {
    _lectureListResponse = Response.loading("fetching lectures from server");
    notifyListeners();

    try {
      List<Lecture> remoteList = await _lectureRepository.loadLecturesRemote();
      log("loaded remote lectures");
      List<Lecture> localList = await _lectureRepository.loadLecturesLocal();
      log("loaded local lectures");

      final mergedLectureList = _mergeLectureLists(remoteList, localList);
      final groupedLectureList = _groupLecturesByPack(mergedLectureList);
      groupedLectureList.sort((p1, p2) => p1.title.toLowerCase().compareTo(p2.title.toLowerCase()));
      groupedLectureList.forEach((pack) => pack.children.sort((l1, l2) => l1.lesson.toLowerCase().compareTo(l2.lesson.toLowerCase())));
      _availableLectures = groupedLectureList;

      _lectureListResponse = Response.completed();
      notifyListeners();
    } catch(e) {
      _lectureListResponse = Response.error(e.toString());
      notifyListeners();
    }
  }

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

  Future<Response> downloadAndSaveLecture(Lecture lecture) async {
    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    File lectureFile = await _lectureRepository.downloadLecture(lecture);

    List<Vocable> vocables;
    try {
      vocables = await _extractAndSaveZipFile(lectureFile);
    } catch(e) {
      log(e.toString());
      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.notPersisted;
      notifyListeners();
      return Response.error(e.toString());
    }

    int newId = await _lectureRepository.insertLecture(lecture);
    vocables.forEach((element) => element.lectureId = newId);
    await _lectureRepository.insertVocables(vocables);

    _availableLectures[indexPack].children[indexLecture].id = newId;
    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.persisted;
    notifyListeners();
    return Response.completed();
  }

  Future<void> updateLecture(Lecture lecture) async {
    log("updating " + lecture.toString());

    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    await _deleteMediaFiles(lecture);
    await _lectureRepository.deleteVocablesByLectureId(lecture.id);
    await _lectureRepository.deleteLecture(lecture);
    lecture.fileName = lecture.fileNameUpdate;
    lecture.fileNameUpdate = null;
    String newDate = Utils.extractDateFromLectureFilename(lecture.fileName);
    lecture.date = newDate;
    await downloadAndSaveLecture(lecture);

    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.persisted;
    notifyListeners();
  }

  Future<void> deleteLecture(Lecture lecture) async {
    log("deleting " + lecture.toString());

    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    await _deleteMediaFiles(lecture);
    await _lectureRepository.deleteVocablesByLectureId(lecture.id);
    await _lectureRepository.deleteLecture(lecture);

    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.notPersisted;
    notifyListeners();
  }

  Future<void> _deleteMediaFiles(Lecture lecture) async {
    String dir = (await getApplicationDocumentsDirectory()).path;

    final dirName = lecture.fileName.split('.')[0];
    final lectureDir = Directory(dir + '/' + dirName);
    lectureDir.deleteSync(recursive: true);
  }

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
}