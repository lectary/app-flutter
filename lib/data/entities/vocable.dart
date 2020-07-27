import 'package:floor/floor.dart';
import 'package:lectary/data/entities/lecture.dart';
import 'package:lectary/models/media_type_enum.dart';

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
  final int id;

  @ColumnInfo(name: "lecture_id", nullable: false)
  final int lectureId;

  @ColumnInfo(nullable: false)
  final String vocable;

  @ColumnInfo(name: "media_type", nullable: false)
  final String mediaType;

  @ColumnInfo(nullable: false)
  final String media; // can contain a path to the video or image or the text content
  
  @ColumnInfo(name: "vocable_progress", nullable: false)
  final int vocableProgress;

  Vocable(
      {this.id,
      this.lectureId,
      this.vocable,
      this.mediaType,
      this.media,
      this.vocableProgress});
}