import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lectary/data/database.dart';
import 'package:lectary/data/entities/lecture.dart';
import 'package:lectary/data/entities/vocable.dart';
import 'package:lectary/services/lectary_api.dart';

/// Repository class for encapsulating data access independent of the source
class LectureRepository {
  final LectaryApi _lectaryApi;
  final LectureDatabase _lectureDatabase;

  LectureRepository({@required lectaryApi, @required lectureDatabase})
      : _lectaryApi = lectaryApi,
        _lectureDatabase = lectureDatabase;

  Future<List<Lecture>> loadLecturesRemote() async {
    return await _lectaryApi.fetchLectures();
  }

  Future<File> downloadLecture(Lecture lecture) async {
    return _lectaryApi.downloadLectureZip(lecture);
  }

  Future<void> saveVocables(List<Vocable> vocableList) async {
    // TODO implement
    return null;
  }

  Stream<List<Lecture>> watchAllLectures() {
    return _lectureDatabase.lectureDao.watchAllLectures();
  }

  Future<List<Lecture>> loadLecturesLocal() async {
    return _lectureDatabase.lectureDao.findAllLectures();
  }

  Future<void> insertLecture(Lecture lecture) {
    return _lectureDatabase.lectureDao.insertLecture(lecture);
  }

  Future<void> updateLecture(Lecture lecture) {
    return _lectureDatabase.lectureDao.updateLecture(lecture);
  }

  Future<void> deleteLecture(Lecture lecture) {
    return _lectureDatabase.lectureDao.deleteLecture(lecture);
  }

  Future<void> dispose() async {
    await _lectureDatabase.close();
  }
}