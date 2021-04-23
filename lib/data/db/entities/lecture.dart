import 'dart:developer';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/utils/exceptions/lecture_exception.dart';
import 'package:lectary/utils/utils.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';


enum LectureStatus { notPersisted, downloading, persisted, removed, updateAvailable }

/// Entity class representing a lecture.
@Entity(tableName: "lectures")
class Lecture {
  @PrimaryKey(autoGenerate: true)
  int id;

  /// Used for showing corresponding status information and providing further actions in the lecture management list
  @ignore
  LectureStatus lectureStatus = LectureStatus.notPersisted;
  /// Used for saving the fileName of an available update
  @ignore
  String fileNameUpdate;

  /// Lecture fileName containing all the metadata
  @ColumnInfo(name: "file_name")
  String fileName;

  @ColumnInfo(name: "file_size")
  int fileSize;

  @ColumnInfo(name: "vocable_count")
  int vocableCount;

  /// Lecture metadata
  String pack;

  String lesson;

  // used for sorting
  @ColumnInfo(name: "lesson_sort")
  String lessonSort;

  @ColumnInfo(name: "lang_media")
  String langMedia;

  @ColumnInfo(name: "lang_vocable")
  String langVocable;

  String audio;

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

  /// Factory constructor to create a new lecture instance from a json.
  /// Returns a new [Lecture] on successful json deserialization.
  /// Returns [Null] on [LectureException] i.e. when mandatory metadata are missing.
  factory Lecture.fromJson(Map<String, dynamic> json) {
    String fileName = json['fileName'];
    Map<String, dynamic> metadata;
    try {
      metadata = extractMetadata(fileName);
    } on LectureException catch(e) {
      String errorMessage = "Invalid lecture: " + e.toString();
      log(errorMessage);
      LectureViewModel.reportErrorToLectaryServer(errorMessage);
      return null;
    }
    return Lecture(
      fileName: fileName,
      fileSize: json['fileSize'],
      vocableCount: json['vocableCount'],
      pack: metadata.remove("PACK"),
      lesson: metadata.remove("LESSON"),
      lessonSort: metadata.remove("LESSON-SORT"),
      langMedia: metadata.remove("LANG-MEDIA"),
      langVocable: metadata.remove("LANG-VOCABLE"),
      audio: metadata.containsKey("AUDIO") ? metadata.remove("AUDIO") : null,
      date: metadata.containsKey("DATE") ? metadata.remove("DATE") : Utils.currentDate(),
      sort: metadata.containsKey("SORT") ? Utils.fillWithLeadingZeros(metadata.remove("SORT")) : null,
    );
  }

  /// Extracts the metadata out of an [Lecture] filename.
  /// Returns a [Map] with the metadata.
  /// Throws [LectureException] if mandatory metadata are missing
  /// Used keys {optional}: PACK, LESSON, LESSON-SORT, LANG-MEDIA, LANG-VOCABLE, {AUDIO}, {DATE}, {SORT}
  @visibleForTesting
  static Map<String, dynamic> extractMetadata(String fileName) {
    const List<String> mandatoryMetadataKeys = ["PACK", "LESSON", "LANG"];
    const List<String> optionalMetadataKeys = ["AUDIO", "DATE", "SORT"];
    const List<String> metadataKeys = [...mandatoryMetadataKeys, ...optionalMetadataKeys];
    Map<String, dynamic> result = Map();
    const List<String> mandatoryResultMetadataKeys = ["PACK", "LESSON", "LESSON-SORT", "LANG-MEDIA", "LANG-VOCABLE"];

    // check fileType
    if (!fileName.contains(".zip"))
      throw new LectureException("Missing .zip ending in filename: $fileName");

    // checking if fileName contains mandatory metadata with key-value separator e.g. 'PACK--'
    mandatoryMetadataKeys.forEach((key) {
      if (!RegExp(key + r'\b-{2}\b').hasMatch(fileName)) {
        throw new LectureException("Lecture has not mandatory metadata!\n"
            "Missing: "
            "$key"
            "\nFile: $fileName"
        );
      }
    });

    // counting number of metadata keys with key-value separator ('KEY--<VALUE>')
    int keyMatchCount = metadataKeys.map((key) => RegExp(key + r'\b-{2}\b').hasMatch(fileName) ? 1 : 0).reduce((i, j) => i + j);
    // The following regex finds all groups of '<key>--<value>' which are followed by at least 2x '-' or '.zip'.
    // Therefore, it doesn't matter if the formal key-separator '---' is malformed and contains only two or more chars of '-'
    List<String> metadata = RegExp(r'([a-zA-Z0-9]+\b--\b.*?)(?=\b--|.zip)').allMatches(fileName).map((e) => e.group(0)).toList();
    // checking if as many key-value pairs could be extracted as the number of matching keys
    if (metadata.length != keyMatchCount) {
      throw new LectureException("Malformed metadata: $fileName");
    }

    for (String metadatum in metadata) {
      List<String> split = metadatum.split("--");
      if (split.length != 2) {
        throw new LectureException("Malformed metadatum: $metadatum of lecture $fileName");
      }
      String metadatumType = split[0];
      String metadatumValue = split[1];

      switch(metadatumType) {
        case "PACK":
          result.putIfAbsent("PACK", () => Utils.deAsciify(metadatumValue).trim());
          break;
        case "LESSON":
          String lesson = Utils.deAsciify(metadatumValue).trim();
          result.putIfAbsent("LESSON", () => lesson);
          result.putIfAbsent("LESSON-SORT", () => Utils.replaceForSort(lesson));
          break;
        case "LANG":
          List<String> langs = metadatumValue.split("-");
          if (langs.length != 2) {
            throw new LectureException("Malformed LANG metadatum: $metadatumValue");
          }
          String langMedia = Utils.deAsciify(langs[0]);
          if (langMedia == "OGS") langMedia = "ÖGS"; // convert legacy 'OGS'-lectures to 'ÖGS'
          result.putIfAbsent("LANG-MEDIA", () => langMedia); // deAsciifying due to possible special german characters like in 'ÖGS'
          result.putIfAbsent("LANG-VOCABLE", () => (langs[1])); // no deAsciifying, because the langs are of ISO 639-1, which does not contain any special characters
          break;
        case "AUDIO":
          result.putIfAbsent("AUDIO", () => metadatumValue);
          break;
        case "DATE":
          // validate date-string, which will be parsed later when checking on updates
          try {
            DateTime.parse(metadatumValue);
            result.putIfAbsent("DATE", () => metadatumValue);
          } catch(FormatException) {
            throw new LectureException("Malformed DATE metadatum: $metadatumValue");
          }
          break;
        case "SORT":
          // ensure that SORT consists of only numbers with a length of 1 to max 5
          var _parseFormat = RegExp(r'^[0-9]{1,5}$');
          if (_parseFormat.hasMatch(metadatumValue)) {
            result.putIfAbsent("SORT", () => metadatumValue);
          } else {
            throw new LectureException("Malformed SORT metadatum: $metadatumValue");
          }
          break;
      }
    }

    // Check again if all mandatory keys could be processed
    mandatoryResultMetadataKeys.forEach((key) {
      if (!result.containsKey(key)) {
        throw new LectureException("Lecture has not mandatory metadata!\n"
            "Missing: "
            "$key"
            "\nFile: $fileName"
        );
      }
    });
    return result;
  }

  @override
  String toString() {
    return 'Lecture{id: $id, lectureStatus: $lectureStatus, fileNameUpdate: $fileNameUpdate, fileName: $fileName, fileSize: $fileSize, vocableCount: $vocableCount, pack: $pack, lesson: $lesson, lessonSort: $lessonSort, langMedia: $langMedia, langVocable: $langVocable, audio: $audio, date: $date, sort: $sort}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lecture &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lectureStatus == other.lectureStatus &&
          fileNameUpdate == other.fileNameUpdate &&
          fileName == other.fileName &&
          fileSize == other.fileSize &&
          vocableCount == other.vocableCount &&
          pack == other.pack &&
          lesson == other.lesson &&
          lessonSort == other.lessonSort &&
          langMedia == other.langMedia &&
          langVocable == other.langVocable &&
          audio == other.audio &&
          date == other.date &&
          sort == other.sort;

  @override
  int get hashCode =>
      id.hashCode ^
      lectureStatus.hashCode ^
      fileNameUpdate.hashCode ^
      fileName.hashCode ^
      fileSize.hashCode ^
      vocableCount.hashCode ^
      pack.hashCode ^
      lesson.hashCode ^
      lessonSort.hashCode ^
      langMedia.hashCode ^
      langVocable.hashCode ^
      audio.hashCode ^
      date.hashCode ^
      sort.hashCode;
}