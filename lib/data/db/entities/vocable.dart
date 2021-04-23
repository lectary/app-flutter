import 'dart:developer';

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/utils/exceptions/vocable_exception.dart';
import 'package:lectary/utils/utils.dart';
import 'package:lectary/data/db/entities/lecture.dart';


/// Entity class representing an vocable, which is part of a [Lecture].
@Entity(
    tableName: "vocables",
    foreignKeys: [
      ForeignKey(
        childColumns: ["lecture_id"],
        parentColumns: ["id"],
        entity: Lecture
      )
    ],
)
class Vocable {
  @PrimaryKey(autoGenerate: true)
  int id;

  @ColumnInfo(name: "lecture_id")
  int lectureId;

  String vocable;

  // used for sorting lexicographic
  @ColumnInfo(name: "vocable_sort")
  String vocableSort;

  @ColumnInfo(name: "media_type")
  String mediaType;

  // contains the path to the media asset
  String media;

  // contains the language of the audio or null if no audio is available
  String audio;

  String sort;
  
  @ColumnInfo(name: "vocable_progress")
  int vocableProgress;

  Vocable(
      {this.id,
      @required this.lectureId,
      @required this.vocable,
      @required this.vocableSort,
      @required this.mediaType,
      @required this.media,
      this.audio,
      this.sort,
      this.vocableProgress = 0})
      : assert(vocable != null),
        assert(vocableSort != null),
        assert(mediaType != null),
        assert(media != null);

  /// Factory constructor to create a new vocable instance from a filePath.
  /// Returns a new [Vocable] on successful metadata extraction.
  /// Returns [Null] on [VocableException] i.e. when media type is unknown.
  factory Vocable.fromFilePath(String filePath) {
    String fileName, extension;
    MediaType mediaType;
    Map<String, dynamic> metadata;
    try {
      // checking whether media type is valid
      extension = Utils.extractFileExtension(filePath);
      mediaType = MediaType.fromString(extension);
      // extracting vocable and possible metadata from fileName (i.e. filename without path and extension)
      fileName = Utils.extractFileName(filePath);
      metadata = _extractMetadata(fileName);
    } catch(e) {
      log("Invalid vocable: " + e.toString());
      return null;
    }
    return Vocable(
      lectureId: null,
      vocable: metadata.remove("VOCABLE"),
      vocableSort: metadata.remove("VOCABLE-SORT"),
      media: filePath,
      mediaType: mediaType.toString(),
      vocableProgress: 0,
      audio: metadata.containsKey("AUDIO") ? metadata.remove("AUDIO") : null,
      sort: metadata.containsKey("SORT") ? Utils.fillWithLeadingZeros(metadata.remove("SORT")) : null,
    );

  }

  /// Extracts the vocable itself and possible metadata out of an [Vocable] filename.
  /// Returns a [Map] with the vocable and meta data.
  /// Used keys {optional}: VOCABLES, {AUDIO}, {SORT}
  static Map<String, dynamic> _extractMetadata(String fileName) {
    Map<String, dynamic> result = Map();

    // check if there are metaData
    if (fileName.contains("---")) {
      List<String> metadata = fileName.split("---");
      // the first one is always the vocable itself
      String vocable = metadata.removeAt(0).trim();
      result.putIfAbsent("VOCABLE", () => vocable);
      result.putIfAbsent("VOCABLE-SORT", () => Utils.replaceForSort(vocable));

      for (String metadatum in metadata) {
        // extracting metaData
        List<String> split = metadatum.split("--");
        if (split.length != 2) {
          log("Malformed metadatum: $metadatum of vocable $fileName");
          // throw new VocableException("Malformed metadatum: $metadatum of vocable $fileName");
          // ignore metadatum for this vocable in case of malformation
          continue;
        }
        String metadatumType = split[0];
        String metadatumValue = split[1];

        switch (metadatumType) {
          case "AUDIO":
            result.putIfAbsent("AUDIO", () => metadatumValue);
            break;
          case "SORT":
            // ensure that SORT consists of only numbers with a length of 1 to max 5
            var _parseFormat = RegExp(r'^[0-9]{1,5}$');
            if (_parseFormat.hasMatch(metadatumValue)) {
              result.putIfAbsent("SORT", () => metadatumValue);
            } else {
              // throw new VocableException("Malformed SORT metadatum: $metadatumValue");
              // ignore metadatum for this vocable in case of malformation
            }
            break;
        }
      }
    } else {
      result.putIfAbsent("VOCABLE", () => fileName);
      result.putIfAbsent("VOCABLE-SORT", () => Utils.replaceForSort(fileName));
    }

    return result;
  }

  @override
  String toString() {
    return 'Vocable{id: $id, lectureId: $lectureId, vocable: $vocable, vocableSort: $vocableSort, mediaType: $mediaType, media: $media, audio: $audio, sort: $sort, vocableProgress: $vocableProgress}';
  }
}