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

  Stream<List<Lecture>> watchAllLectures() {
    return _lectureDatabase.lectureDao.watchAllLectures();
  }

  Future<List<Lecture>> loadLecturesLocal() async {
    return _lectureDatabase.lectureDao.findAllLectures();
  }

  Future<int> insertLecture(Lecture lecture) {
    return _lectureDatabase.lectureDao.insertLecture(lecture);
  }

  Future<void> updateLecture(Lecture lecture) {
    return _lectureDatabase.lectureDao.updateLecture(lecture);
  }

  Future<void> deleteLecture(Lecture lecture) {
    return _lectureDatabase.lectureDao.deleteLecture(lecture);
  }

  Future<List<Vocable>> findAllVocables() {
    return _lectureDatabase.vocableDao.findAllVocables();
  }

  Future<List<Vocable>> findVocablesByLectureId(int lectureId) {
    return _lectureDatabase.vocableDao.findVocablesByLectureId(lectureId);
  }

  Future<List<Vocable>> findVocablesByLecturePack(String lecturePack) {
    return _lectureDatabase.vocableDao.findVocablesByLecturePack(lecturePack);
  }

  Future<List<int>> insertVocables(List<Vocable> vocables) {
    return _lectureDatabase.vocableDao.insertVocables(vocables);
  }

  Future<void> updateVocable(Vocable vocable) {
    return _lectureDatabase.vocableDao.updateVocable(vocable);
  }

  Future<void> deleteVocablesByLectureId(int lectureId) {
    return _lectureDatabase.vocableDao.deleteVocablesByLectureId(lectureId);
  }

  Future<void> deleteAllVocables() {
    return _lectureDatabase.vocableDao.deleteAllVocables();
  }

  Future<void> dispose() async {
    await _lectureDatabase.close();
  }
}