import 'dart:developer';

import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:lectary/utils/exceptions/coding_exception.dart';
import 'package:lectary/utils/utils.dart';

enum CodingStatus { notPersisted, persisted, removed, updateAvailable }

@Entity(tableName: "codings")
class Coding {
  @PrimaryKey(autoGenerate: true)
  int id;

  @ignore
  CodingStatus codingStatus;
  @ignore
  String fileNameUpdate;

  @ColumnInfo(name: "file_name", nullable: false)
  String fileName;

  @ColumnInfo(nullable: false)
  String lang;

  @ColumnInfo(nullable: false)
  String date;

  Coding(
      {this.id,
      @required this.fileName,
      @required this.lang,
      @required this.date});

  factory Coding.fromJson(Map<String, dynamic> json) {
    String fileName = json['fileName'];
    Map<String, dynamic> metaInfo;
    try {
      metaInfo = _extractMetaInformation(fileName);
    } on CodingException catch(e) {
      log("Invalid abstract: ${e.toString()}");
      return null;
    }
    return Coding(
      fileName: fileName,
      lang: metaInfo.remove("CODING"),
      date: metaInfo.remove("DATE")
    );
  }

  static Map<String, dynamic> _extractMetaInformation(String fileName) {
    Map<String, dynamic> result = Map();

    String fileWithoutType = fileName.split(".json")[0];
    if (!fileWithoutType.contains("CODING") || !fileWithoutType.contains("DATE")) {
      log("File has not mandatory meta information! File: " + fileWithoutType);
      throw new CodingException("File has not mandatory meta information!\n"
          "Missing:"
          "${!fileWithoutType.contains("CODING") ? " CODING " : ""}"
          "${!fileWithoutType.contains("DATE") ? " DATE " : ""}"
      );
    }

    List<String> metaInfos = fileWithoutType.split("---");
    for (String metaInfo in metaInfos) {
      String metaInfoType = metaInfo.split("--")[0];
      String metaInfoValue = metaInfo.split("--")[1];

      switch(metaInfoType) {
        case "CODING":
          result.putIfAbsent("CODING", () => Utils.deAsciify(metaInfoValue));
          break;
        case "DATE":
          result.putIfAbsent("DATE", () => metaInfoValue);
          break;
      }
    }
    return result;
  }

  @override
  String toString() {
    return 'Coding{id: $id, codingStatus: $codingStatus, fileNameUpdate: $fileNameUpdate, fileName: $fileName, lang: $lang, date: $date}';
  }
}


@Entity(
  tableName: "coding_entries",
  foreignKeys: [
    ForeignKey(
        childColumns: ["coding_id"], parentColumns: ["id"], entity: Coding)
  ],
)
class CodingEntry {
  @PrimaryKey(autoGenerate: true)
  int id;

  @ColumnInfo(name: "coding_id", nullable: false)
  int codingId;

  @ColumnInfo(nullable: false)
  String char;

  @ColumnInfo(nullable: false)
  String ascii;

  CodingEntry(
      {this.id, this.codingId, @required this.char, @required this.ascii});
}