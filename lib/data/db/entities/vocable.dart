import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

import 'lecture.dart';

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

  @ColumnInfo(name: "lecture_id", nullable: false)
  int lectureId;

  @ColumnInfo(nullable: false)
  String vocable;

  // used for sorting
  @ColumnInfo(name: "vocable_sort", nullable: false)
  String vocableSort;

  @ColumnInfo(name: "media_type", nullable: false)
  String mediaType;

  @ColumnInfo(nullable: false)
  String media; // can contain a path to the video or image or the text content
  
  @ColumnInfo(name: "vocable_progress", nullable: false)
  int vocableProgress;

  Vocable(
      {this.id,
      @required this.lectureId,
      @required this.vocable,
      @required this.vocableSort,
      @required this.mediaType,
      @required this.media,
      @required this.vocableProgress});

  @override
  String toString() {
    return 'Vocable{id: $id, lectureId: $lectureId, vocable: $vocable, vocableSort: $vocableSort, mediaType: $mediaType, media: $media, vocableProgress: $vocableProgress}';
  }
}