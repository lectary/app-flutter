import 'dart:developer';

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/utils/exceptions/abstract_exception.dart';
import 'package:lectary/utils/utils.dart';


enum AbstractStatus { notPersisted, persisted, removed, updateAvailable }

@Entity(tableName: "abstracts")
class Abstract {
  @PrimaryKey(autoGenerate: true)
  int id;

  @ignore
  AbstractStatus abstractStatus;
  @ignore
  String fileNameUpdate;

  @ColumnInfo(name: "file_name", nullable: false)
  String fileName;

  @ColumnInfo(nullable: false)
  String pack;

  @ColumnInfo(nullable: false)
  String text;

  @ColumnInfo(nullable: false)
  String date;

  Abstract(
      {this.id,
      @required this.fileName,
      @required this.pack,
      this.text,
      @required this.date})
      : assert(fileName != null),
        assert(pack != null),
        assert(date != null);

  factory Abstract.fromJson(Map<String, dynamic> json) {
    String fileName = json['fileName'];
    Map<String, dynamic> metaInfo;
    try {
      metaInfo = _extractMetaInformation(fileName);
    } on AbstractException catch(e) {
      log("Invalid abstract: ${e.toString()}");
      return null;
    }
    return Abstract(
      fileName: fileName,
      pack: metaInfo.remove("ABSTRACT"),
      date: metaInfo.remove("DATE")
    );
  }

  static Map<String, dynamic> _extractMetaInformation(String fileName) {
    Map<String, dynamic> result = Map();

    String fileWithoutType = fileName.split(".txt")[0];
    if (!fileWithoutType.contains("ABSTRACT") || !fileWithoutType.contains("DATE")) {
      log("File has not mandatory meta information! File: " + fileWithoutType);
      throw new AbstractException("File has not mandatory meta information!\n"
          "Missing:"
          "${!fileWithoutType.contains("ABSTRACT") ? " ABSTRACT " : ""}"
          "${!fileWithoutType.contains("DATE") ? " DATE " : ""}"
      );
    }

    List<String> metaInfos = fileWithoutType.split("---");
    for (String metaInfo in metaInfos) {
      String metaInfoType = metaInfo.split("--")[0];
      String metaInfoValue = metaInfo.split("--")[1];

      switch(metaInfoType) {
        case "ABSTRACT":
          result.putIfAbsent("ABSTRACT", () => Utils.deAsciify(metaInfoValue));
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
    return 'Abstract{id: $id, fileName: $fileName, pack: $pack, text: $text, date: $date}';
  }
}