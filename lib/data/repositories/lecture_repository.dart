import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lectary/data/api/lectary_api.dart';
import 'package:lectary/data/db/database.dart';
import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/models/lectary_overview.dart';

/// Repository class for encapsulating data access independent of the source
class LectureRepository {
  final LectaryApi _lectaryApi;
  final LectureDatabase _lectureDatabase;

  LectureRepository({@required lectaryApi, @required lectureDatabase})
      : _lectaryApi = lectaryApi,
        _lectureDatabase = lectureDatabase;

  Future<LectaryData> loadLectaryData() async {
    return await _lectaryApi.fetchLectaryData();
  }

  Future<void> dispose() async {
    await _lectureDatabase.close();
  }

  ///////////////////
  // Lectures
  ///////////////////
  Future<File> downloadLecture(Lecture lecture) async {
    return _lectaryApi.downloadLectureZip(lecture);
  }

  Stream<List<Lecture>> watchAllLectures() {
    return _lectureDatabase.lectureDao.watchAllLectures();
  }

  Future<List<Lecture>> loadLecturesLocal() async {
    return _lectureDatabase.lectureDao.findAllLectures();
  }

  Future<List<Lecture>> findAllLecturesWithLang(String lang) {
    return _lectureDatabase.lectureDao.findAllLecturesWithLang(lang);
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

  Future<void> deleteAllLectures() {
    return _lectureDatabase.lectureDao.deleteAllLectures();
  }

  ///////////////////
  // Vocables
  ///////////////////
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

  Future<void >updateVocables(List<Vocable> vocables) {
    return _lectureDatabase.vocableDao.updateVocables(vocables);
  }

  Future<void> deleteVocablesByLectureId(int lectureId) {
    return _lectureDatabase.vocableDao.deleteVocablesByLectureId(lectureId);
  }

  Future<void> deleteAllVocables() {
    return _lectureDatabase.vocableDao.deleteAllVocables();
  }

  Future<void> resetAllVocableProgress() {
    return _lectureDatabase.vocableDao.resetAllVocableProgress();
  }

  ///////////////////
  // Abstracts
  ///////////////////
  Future<File> downloadAbstract(Abstract abstract) async {
    return _lectaryApi.downloadAbstractFile(abstract);
  }

  Future<List<Abstract>> findAllAbstracts() {
    return _lectureDatabase.abstractDao.findAllAbstracts();
  }

  Future<int> insertAbstract(Abstract abstract) {
    return _lectureDatabase.abstractDao.insertAbstract(abstract);
  }

  Future<void> updateAbstract(Abstract abstract) {
    return _lectureDatabase.abstractDao.updateAbstract(abstract);
  }

  Future<void> deleteAbstract(Abstract abstract) {
    return _lectureDatabase.abstractDao.deleteAbstract(abstract);
  }

  ///////////////////
  // Codings
  ///////////////////
  Future<File> downloadCoding(Coding coding) async {
    return _lectaryApi.downloadCodingFile(coding);
  }

  Future<List<Coding>> findAllCodings() {
    return _lectureDatabase.codingDao.findAllCodings();
  }

  Future<int> insertCoding(Coding coding) {
    return _lectureDatabase.codingDao.insertCoding(coding);
  }

  Future<void> updateCoding(Coding coding) {
    return _lectureDatabase.codingDao.updateCoding(coding);
  }

  Future<void> deleteCoding(Coding coding) {
    return _lectureDatabase.codingDao.deleteCoding(coding);
  }

  Future<void> deleteAllCoding() {
    return _lectureDatabase.codingDao.deleteAllCodings();
  }

  ///////////////////
  // CodingEntries
  ///////////////////
  Future<List<CodingEntry>> findAllCodingEntries() {
    return _lectureDatabase.codingDao.findAllCodingEntries();
  }

  Future<List<CodingEntry>> findAllCodingEntriesByCodingId(int codingId) {
    return _lectureDatabase.codingDao.findAllCodingEntriesByCodingId(codingId);
  }

  Future<List<int>> insertCodingEntries(List<CodingEntry> codingEntries) {
    return _lectureDatabase.codingDao.insertCodingEntries(codingEntries);
  }

  Future<void> updateCodingEntry(CodingEntry codingEntry) {
    return _lectureDatabase.codingDao.updateCodingEntry(codingEntry);
  }

  Future<void> deleteCodingEntriesByCodingId(int codingId) {
    return _lectureDatabase.codingDao.deleteCodingEntriesByCodingId(codingId);
  }

  Future<void> deleteAllCodingEntries() {
    return _lectureDatabase.codingDao.deleteAllCodingEntries();
  }
}