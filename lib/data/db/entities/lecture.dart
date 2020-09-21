import 'dart:developer';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/utils/exceptions/lecture_exception.dart';
import 'package:lectary/utils/utils.dart';

enum LectureStatus { notPersisted, downloading, persisted, removed, updateAvailable }


/// Model class representing a lecture pack
@Entity(tableName: "lectures")
class Lecture {
  @PrimaryKey(autoGenerate: true)
  int id;

  /// Used for showing corresponding info icons in the lecture management list
  @ignore
  LectureStatus lectureStatus = LectureStatus.notPersisted;
  @ignore
  String fileNameUpdate;

  /// Lecture pack properties (.zip)
  @ColumnInfo(name: "file_name", nullable: false)
  String fileName;

  @ColumnInfo(name: "file_size", nullable: false)
  int fileSize;

  @ColumnInfo(name: "vocable_count", nullable: false)
  int vocableCount;

  /// Possible meta information
  @ColumnInfo(nullable: false)
  String pack;

  @ColumnInfo(nullable: false)
  String lesson;

  // used for sorting
  @ColumnInfo(name: "lesson_sort", nullable: false)
  String lessonSort;

  @ColumnInfo(name: "lang_media", nullable: false)
  String langMedia;

  @ColumnInfo(name: "lang_vocable", nullable: false)
  String langVocable;

  String audio;

  @ColumnInfo(nullable: false)
  String date;

  String sort;

  Lecture(
      {this.id,
      @required this.fileName,
      @required this.fileSize,
      @required this.vocableCount,
      @required this.pack,
      @required this.lesson,
      @required this.lessonSort,
      @required this.langMedia,
      @required this.langVocable,
      this.audio,
      this.date,
      this.sort})
      : assert(fileName != null),
        assert(fileSize != null),
        assert(vocableCount != null),
        assert(pack != null),
        assert(lesson != null),
        assert(lessonSort != null),
        assert(langMedia != null),
        assert(langVocable != null);

  @ignore
  Lecture.clone(Lecture lecture) {
    this.id = lecture.id;
    this.lectureStatus = lecture.lectureStatus;
    this.fileNameUpdate = lecture.fileNameUpdate;
    this.fileName = lecture.fileName;
    this.fileSize = lecture.fileSize;
    this.vocableCount = lecture.vocableCount;
    this.pack = lecture.pack;
    this.lesson = lecture.lesson;
    this.lessonSort = lecture.lessonSort;
    this.langMedia = lecture.langMedia;
    this.langVocable = lecture.langVocable;
    this.audio = lecture.audio;
    this.date = lecture.date;
    this.sort = lecture.sort;
  }

  /// Deserialization from json
  /// returns [Lecture] on successful deserialization
  /// returns [Null] on [LectureException] i.e. when mandatory meta information are missing
  factory Lecture.fromJson(Map<String, dynamic> json) {
    String fileName = json['fileName'];
    Map<String, dynamic> metaData;
    try {
      metaData = Utils.extractMetaDataFromLectureFile(fileName);
    } on LectureException catch(e) {
      log("Invalid lecture: " + e.toString());
      return null;
    }
    return Lecture(
      fileName: fileName,
      fileSize: json['fileSize'],
      vocableCount: json['vocableCount'],
      pack: metaData.remove("PACK"),
      lesson: metaData.remove("LESSON"),
      lessonSort: metaData.remove("LESSON-SORT"),
      langMedia: metaData.remove("LANG-MEDIA"),
      langVocable: metaData.remove("LANG-VOCABLE"),
      audio: metaData.containsKey("AUDIO") ? metaData.remove("AUDIO") : null,
      date: metaData.containsKey("DATE") ? metaData.remove("DATE") : Utils.currentDate(),
      sort: metaData.containsKey("SORT") ? Utils.fillWithLeadingZeros(metaData.remove("SORT")) : null,
    );
  }

  @override
  String toString() {
    return 'Lecture{id: $id, lectureStatus: $lectureStatus, fileNameUpdate: $fileNameUpdate, fileName: $fileName, fileSize: $fileSize, vocableCount: $vocableCount, pack: $pack, lesson: $lesson, lessonSort: $lessonSort, langMedia: $langMedia, langVocable: $langVocable, audio: $audio, date: $date, sort: $sort}';
  }
}