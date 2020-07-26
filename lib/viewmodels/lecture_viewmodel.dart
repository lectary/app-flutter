import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lectary/data/entities/lecture.dart';
import 'package:lectary/data/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lecture_package.dart';

import 'package:collection/collection.dart';

enum Status { loading, error, completed }

class LectureViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

  List<Lecture> _availableLectures = List();
  Status _status = Status.completed;
  String _message;

  List<Lecture> get availableLectures => _availableLectures;
  Status get status => _status;
  String get message => _message;

  Stream<List<LecturePackage>> localLectures;

  LectureViewModel({@required lectureRepository})
      : _lectureRepository = lectureRepository
  {
    localLectures = _lectureRepository.watchAllLectures()
        .map((list) => groupLecturesByPack(list));
  }

  List<LecturePackage> groupLecturesByPack(List<Lecture> lectureList) {
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

      _availableLectures = _mergeLectureLists(remoteList, localList);

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

    resultList.sort((e1, e2) => e1.lesson.toLowerCase().compareTo(e2.lesson.toLowerCase()));

    return resultList;
  }

  Future<void> loadSingleLectureFromServer(int lectureIndex) async {
    _availableLectures[lectureIndex].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    // TODO unzip
    File lectureFile = await _lectureRepository.downloadLecture(_availableLectures[lectureIndex]);


    // TODO persist
    List<Vocable> vocableList = List();
    _lectureRepository.saveVocables(vocableList);


    _availableLectures[lectureIndex].lectureStatus = LectureStatus.persisted;
    notifyListeners();
  }
}