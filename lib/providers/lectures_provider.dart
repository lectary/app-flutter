import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/models/lecture.dart';
import 'package:lectary/services/lectary_api.dart';

enum Status { loading, error, completed }

class LecturesProvider with ChangeNotifier {
  List<Lecture> _lectureList = List();
  Status _status = Status.completed;

  List<Lecture> get lectureList => _lectureList;
  Status get status => _status;

  Future<void> loadLecturesFromServer() async {
    _status = Status.loading;
    notifyListeners();

    try {
      _lectureList = await LectaryApi().fetchLectures();
      _status = Status.completed;
      notifyListeners();
    } catch(e) {
      _status = Status.error;
      notifyListeners();
    }
  }

  Future<void> loadSingleLectureFromServer(int lectureIndex) async {
    log("loading single lecture");
    // TODO
  }

  Future<void> loadLecturesFromLocalDB() async {
    log("loading local lectures");
    // TODO
  }
}