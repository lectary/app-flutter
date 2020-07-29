import 'dart:developer';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
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

  @ColumnInfo(nullable: false)
  String lang;

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
      @required this.lang,
      this.audio,
      this.date,
      this.sort});

  /// Deserialization from json
  factory Lecture.fromJson(Map<String, dynamic> json) {
    String fileName = json['fileName'];
    Map<String, dynamic> metaInfo;
    try {
      metaInfo = Utils.extractMetaInformation(fileName);
    } catch(e) {
      log("Extracting:" + e.toString());
    }
    return Lecture(
      fileName: fileName,
      fileSize: json['fileSize'],
      vocableCount: json['vocableCount'],
      pack: metaInfo.remove("PACK"),
      lesson: metaInfo.remove("LESSON"),
      lang: metaInfo.remove("LANG"),
      audio: metaInfo.containsKey("AUDIO") ? metaInfo.remove("AUDIO") : null,
      date: metaInfo.containsKey("DATE") ? metaInfo.remove("DATE") : Utils.currentDate(),
      sort: metaInfo.containsKey("SORT") ? Utils.fillWithLeadingZeros(metaInfo.remove("SORT")) : null,
    );
  }
}