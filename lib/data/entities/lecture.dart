import 'dart:developer';
import 'package:floor/floor.dart';
import 'package:lectary/utils/utils.dart';

enum LectureStatus { notPersisted, downloading, persisted, removed, updateAvailable }


/// Model class representing a lecture pack
@Entity(tableName: "lectures")
class Lecture {
  @PrimaryKey(autoGenerate: true)
  final int id;

  /// Used for showing corresponding info icons in the lecture management list
  @ignore
  LectureStatus lectureStatus = LectureStatus.notPersisted;

  /// Lecture pack properties (.zip)
  @ColumnInfo(name: "file_name", nullable: false)
  final String fileName;

  @ColumnInfo(name: "file_size", nullable: false)
  final int fileSize;

  @ColumnInfo(name: "vocable_count", nullable: false)
  final int vocableCount;

  /// Possible meta information
  @ColumnInfo(nullable: false)
  String pack;

  @ColumnInfo(nullable: false)
  String lesson;

  @ColumnInfo(nullable: false)
  String lang;

  String audio;

  String date;

  int sort;

  Lecture(
      {this.id,
      this.fileName,
      this.fileSize,
      this.vocableCount,
      this.pack,
      this.lesson,
      this.lang,
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
      date: metaInfo.containsKey("DATE") ? metaInfo.remove("DATE") : null,
      sort: metaInfo.containsKey("SORT") ? metaInfo.remove("SORT") : null,
    );
  }
}