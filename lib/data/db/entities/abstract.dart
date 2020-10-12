import 'dart:developer';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/utils/exceptions/abstract_exception.dart';
import 'package:lectary/utils/utils.dart';


enum AbstractStatus { notPersisted, persisted, removed, updateAvailable }

/// Entity class representing an abstract, which is used as description for a lecture package.
@Entity(tableName: "abstracts")
class Abstract {
  @PrimaryKey(autoGenerate: true)
  int id;

  /// Used for automatically managing (e.g. downloading) abstracts
  @ignore
  AbstractStatus abstractStatus;
  /// Used for saving the fileName of an available update
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

  /// Factory constructor to create a new abstract instance from a json.
  /// Returns a new [Abstract] on successful json deserialization.
  /// Returns [Null] on [AbstractException] i.e. when metadata are malformed.
  factory Abstract.fromJson(Map<String, dynamic> json) {
    String fileName = json['fileName'];
    Map<String, dynamic> metadata;
    try {
      metadata = _extractMetadata(fileName);
    } on AbstractException catch(e) {
      log("Invalid abstract: ${e.toString()}");
      return null;
    }
    return Abstract(
      fileName: fileName,
      pack: metadata.remove("ABSTRACT"),
      date: metadata.remove("DATE")
    );
  }

  /// Extracts metadata of the abstract fileName.
  /// Returns a [Map] with the metadata.
  /// Throws [AbstractException] if mandatory metadata are missing
  /// Used keys: ABSTRACT, DATE
  static Map<String, dynamic> _extractMetadata(String fileName) {
    Map<String, dynamic> result = Map();

    String fileWithoutType = fileName.split(".txt")[0];
    if (!fileWithoutType.contains("ABSTRACT") || !fileWithoutType.contains("DATE")) {
      log("Abstract has not mandatory metadata! Abstract: " + fileWithoutType);
      throw new AbstractException("Abstract has not mandatory metadata!\n"
          "Missing:"
          "${!fileWithoutType.contains("ABSTRACT") ? " ABSTRACT " : ""}"
          "${!fileWithoutType.contains("DATE") ? " DATE " : ""}"
      );
    }

    List<String> metadata = fileWithoutType.split("---");
    for (String metadatum in metadata) {
      String metadatumType = metadatum.split("--")[0];
      String metadatumValue = metadatum.split("--")[1];

      switch(metadatumType) {
        case "ABSTRACT":
          result.putIfAbsent("ABSTRACT", () => Utils.deAsciify(metadatumValue));
          break;
        case "DATE":
          // validate date-format, which it will be parsed later when checking on updates
          try {
            DateTime.parse(metadatumValue);
            result.putIfAbsent("DATE", () => metadatumValue);
          } catch(FormatException) {
            throw new AbstractException("Malformed DATE metadatum: $metadatumValue");
          }
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