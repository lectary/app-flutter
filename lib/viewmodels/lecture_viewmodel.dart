import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/models/lecture.dart';
import 'package:lectary/repositories/lecture_repository.dart';

enum Status { loading, error, completed }

class LectureViewModel with ChangeNotifier {
  LectureRepository _lectureRepository = LectureRepository();

  List<Lecture> _lectureList = List();
  Status _status = Status.completed;
  String _message;

  List<Lecture> get lectureList => _lectureList;
  Status get status => _status;
  String get message => _message;

  Future<void> loadLectures() async {
    _status = Status.loading;
    notifyListeners();

    // TODO refactor to fetch in parallel
//    final lectureLists = await Future.wait([
//      loadLectures(),
//      loadLecturesFromLocalDB()
//    ]);
//
//    final lecturesFromServer = lectureLists[0];
//    final lecturesFromLocalDB = lectureLists[1];

    try {
      List<Lecture> remoteList = await _lectureRepository.loadLecturesRemote();
      log("loaded remote lectures");
      List<Lecture> localList = await _lectureRepository.loadLecturesLocal();
      log("loaded local lectures");

      _lectureList = _mergeLectureLists(remoteList, localList);

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
          if (remote.date.isBefore(local.date)) {
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
    _lectureList[lectureIndex].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    // TODO unzip

    // TODO persist
  }
}