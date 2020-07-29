import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/entities/lecture.dart';
import 'package:lectary/data/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lecture_package.dart';

import 'package:collection/collection.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:path_provider/path_provider.dart';

enum Status { loading, error, completed }

class LectureViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

  List<LecturePackage> _availableLectures = List();
  Status _status = Status.completed;
  String _message;

  List<LecturePackage> get availableLectures => _availableLectures;
  Status get status => _status;
  String get message => _message;

  List<Vocable> _currentVocables = List();
  List<Vocable> get currentVocables => _currentVocables;

  Stream<List<LecturePackage>> localLectures;

  LectureViewModel({@required lectureRepository})
      : _lectureRepository = lectureRepository
  {
    loadLocalLectures();
  }

  loadLocalLectures() {
    localLectures = _lectureRepository.watchAllLectures()
        .map((list) => _groupLecturesByPack(list));
  }

  List<LecturePackage> _groupLecturesByPack(List<Lecture> lectureList) {
    final lecturesByPack = groupBy(lectureList, (lecture) => (lecture as Lecture).pack);
    List<LecturePackage> packList = List();
    lecturesByPack.forEach((key, value) => packList.add(LecturePackage(key, value)));
    return packList;
  }

  /*@override
  void dispose() {
    _lectureRepository.dispose();
    super.dispose();
  }*/

  Future<void> loadLectures() async {
    _status = Status.loading;
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

      _status = Status.completed;
      notifyListeners();
    } catch(e) {
      _status = Status.error;
      _message = e.toString();
      notifyListeners();
    }
  }

  List<Lecture> _mergeLectureLists(List<Lecture> remoteList, List<Lecture> localList) {
    List<Lecture> resultList = remoteList;

    resultList.forEach((remote) {
      localList.forEach((local) {
        if (remote.lesson == local.lesson) {
          if (DateTime.parse(remote.date).isBefore(DateTime.parse(local.date))) {
            remote.lectureStatus = LectureStatus.updateAvailable;
          } else {
            remote.lectureStatus = LectureStatus.persisted;
          }
        }
      });
    });

    localList.forEach((e1) {
      if (resultList.any((e2) => e1.lesson == e2.lesson) == false) {
        e1.lectureStatus = LectureStatus.removed;
        resultList.add(e1);
      }
    });

    return resultList;
  }

  Future<void> downloadAndSaveLecture(Lecture lecture) async {
    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    File lectureFile = await _lectureRepository.downloadLecture(lecture);

    // TODO unzip and get lecture id before
    List<Vocable> vocables;
    try {
      vocables = await _extractAndSaveZipFile(lectureFile);
    } catch(e) {
      // TODO error handling
    }

    // TODO persist
    int newId = await _lectureRepository.insertLecture(lecture);
    vocables.forEach((element) => element.lectureId = newId);
    await _lectureRepository.insertVocables(vocables);

    _availableLectures[indexPack].children[indexLecture].id = newId;
    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.persisted;
    notifyListeners();
  }

  Future<void> updateLecture(Lecture lecture) async {
    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    await deleteLecture(lecture);
    await downloadAndSaveLecture(lecture);

    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.persisted;
    notifyListeners();
  }

  Future<void> deleteLecture(Lecture lecture) async {
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
    var bytes = zipFile.readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);

    List<Vocable> vocables = List();

    String dir = (await getApplicationDocumentsDirectory()).path;

    for (ArchiveFile file in archive) {
      // file.name holds archive name plus actual filename
      String fileName = '$dir/${file.name}';

      if (file.isFile) {
        String vocable = file.name.substring(file.name.indexOf('/')+1, file.name.indexOf('.'));
        String extension = file.name.substring(file.name.indexOf('.')+1, file.name.length).toUpperCase();

        // TODO refactor to act purely as a check/validation
        MediaType mediaType = getMediaTypeFromString(extension);

        // save to a local file
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
      } else {
        log("Found a non-file: " + file.name);
      }
    }
    vocables.forEach((e) => log("Vocable: ${e.vocable}\nmedia: ${e.media}\nmedia-type: ${e.mediaType}"));

    return vocables;
  }
}