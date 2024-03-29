import 'dart:developer';

import 'package:floor/floor.dart';
import 'package:lectary/utils/exceptions/abstract_exception.dart';
import 'package:lectary/utils/utils.dart';

enum AbstractStatus { notPersisted, persisted, removed, updateAvailable }

/// Entity class representing an abstract, which is used as description for a lecture package.
@Entity(tableName: "abstracts")
class Abstract {
  @PrimaryKey(autoGenerate: true)
  int? id;

  /// Used for automatically managing (e.g. downloading) abstracts
  @ignore
  AbstractStatus? abstractStatus;

  /// Used for saving the fileName of an available update
  @ignore
  String? fileNameUpdate;

  @ColumnInfo(name: "file_name")
  String fileName;

  String pack;

  String text;

  String date;

  Abstract({
    this.id,
    required this.fileName,
    required this.pack,
    required this.text,
    required this.date,
  });

  /// Factory constructor to create a new abstract instance from a json.
  /// Returns a new [Abstract] on successful json deserialization.
  /// Returns [Null] on [AbstractException] i.e. when metadata are malformed.
  static Abstract? fromJson(Map<String, dynamic> json) {
    String fileName = json['fileName'];
    Map<String, dynamic> metadata;
    try {
      metadata = _extractMetadata(fileName);
    } on AbstractException catch (e) {
      log("Invalid abstract: ${e.toString()}");
      return null;
    }
    return Abstract(
      fileName: fileName,
      pack: metadata.remove("ABSTRACT"),
      date: metadata.remove("DATE"),
      text: "", // temporary default value, will be assigned later when persisted
    );
  }

  /// Extracts metadata of the abstract fileName.
  /// Returns a [Map] with the metadata.
  /// Throws [AbstractException] if mandatory metadata are missing
  /// Used keys: ABSTRACT, DATE
  static Map<String, dynamic> _extractMetadata(String fileName) {
    Map<String, dynamic> result = {};

    String fileWithoutType = fileName.split(".txt")[0];
    if (!fileWithoutType.contains("ABSTRACT") || !fileWithoutType.contains("DATE")) {
      log("Abstract has not mandatory metadata! Abstract: $fileWithoutType");
      throw AbstractException("Abstract has not mandatory metadata!\n"
          "Missing:"
          "${!fileWithoutType.contains("ABSTRACT") ? " ABSTRACT " : ""}"
          "${!fileWithoutType.contains("DATE") ? " DATE " : ""}");
    }

    List<String> metadata = fileWithoutType.split("---");
    for (String metadatum in metadata) {
      String metadatumType = metadatum.split("--")[0];
      String metadatumValue = metadatum.split("--")[1];

      switch (metadatumType) {
        case "ABSTRACT":
          result.putIfAbsent("ABSTRACT", () => Utils.deAsciify(metadatumValue));
          break;
        case "DATE":
          // validate date-format, which it will be parsed later when checking on updates
          try {
            DateTime.parse(metadatumValue);
            result.putIfAbsent("DATE", () => metadatumValue);
          } on FormatException {
            throw AbstractException("Malformed DATE metadatum: $metadatumValue");
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
