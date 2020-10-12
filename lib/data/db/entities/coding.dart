import 'dart:developer';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:lectary/utils/exceptions/coding_exception.dart';
import 'package:lectary/utils/utils.dart';


enum CodingStatus { notPersisted, persisted, removed, updateAvailable }

/// Entity class representing a coding which is linked to a set of [CodingEntry].
/// It is used to decode additional special characters in vocables.
@Entity(tableName: "codings")
class Coding {
  @PrimaryKey(autoGenerate: true)
  int id;

  /// Used for automatically managing (e.g. downloading) codings
  @ignore
  CodingStatus codingStatus;
  /// Used for saving the fileName of an available update
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
      @required this.date})
      : assert(fileName != null),
        assert(lang != null),
        assert(date != null);

  /// Factory constructor to create a new coding instance from a json.
  /// Returns a new [Coding] on successful json deserialization.
  /// Returns [Null] on [CodingException] i.e. when metadata are malformed.
  factory Coding.fromJson(Map<String, dynamic> json) {
    String fileName = json['fileName'];
    Map<String, dynamic> metadata;
    try {
      metadata = _extractMetadata(fileName);
    } on CodingException catch(e) {
      log("Invalid abstract: ${e.toString()}");
      return null;
    }
    return Coding(
      fileName: fileName,
      lang: metadata.remove("CODING"),
      date: metadata.remove("DATE")
    );
  }

  /// Extracts metadata of the coding fileName.
  /// Returns a [Map] with the metadata.
  /// Throws [CodingException] if mandatory metadata are missing
  /// Used keys: CODING, DATE
  static Map<String, dynamic> _extractMetadata(String fileName) {
    Map<String, dynamic> result = Map();

    String fileWithoutType = fileName.split(".json")[0];
    if (!fileWithoutType.contains("CODING") || !fileWithoutType.contains("DATE")) {
      log("Coding has not mandatory metadata! Coding: " + fileWithoutType);
      throw new CodingException("Coding has not mandatory metadata!\n"
          "Missing:"
          "${!fileWithoutType.contains("CODING") ? " CODING " : ""}"
          "${!fileWithoutType.contains("DATE") ? " DATE " : ""}"
      );
    }

    List<String> metadata = fileWithoutType.split("---");
    for (String metadatum in metadata) {
      String metadatumType = metadatum.split("--")[0];
      String metadatumValue = metadatum.split("--")[1];

      switch(metadatumType) {
        case "CODING":
          result.putIfAbsent("CODING", () => Utils.deAsciify(metadatumValue));
          break;
        case "DATE":
          // validate date-format, which it will be parsed later when checking on updates
          try {
            DateTime.parse(metadatumValue);
            result.putIfAbsent("DATE", () => metadatumValue);
          } catch(FormatException) {
            throw new CodingException("Malformed DATE metadatum: $metadatumValue");
          }
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


/// Entity class representing a specific coding entry (a char with the corresponding ascii encoding).
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