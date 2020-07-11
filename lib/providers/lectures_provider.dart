import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/models/lecture.dart';
import 'package:lectary/services/lectary_api.dart';

class LecturesProvider with ChangeNotifier {
  Future<List<Lecture>> futureLecturesFromServer;

  void loadLecturesFromServer() {
    futureLecturesFromServer = LectaryApi().fetchLectures();
  }

  void loadLectureFromServer() {
    log("test");
  }
}