import 'package:floor/floor.dart';
import 'package:lectary/data/db/entities/vocable.dart';

@dao
abstract class VocableDao {

  @Query("SELECT vocables.* FROM vocables LEFT JOIN lectures ON vocables.lecture_id = lectures.id "
      "WHERE lang_media = :langMedia ORDER BY vocable_sort ASC")
  Future<List<Vocable>> findVocablesByLangMedia(String langMedia);

  @Query("SELECT vocables.* FROM vocables LEFT JOIN lectures ON vocables.lecture_id = lectures.id "
      "WHERE lecture_id = :lectureId AND lang_media = :langMedia ORDER BY vocable_sort ASC")
  Future<List<Vocable>> findVocablesByLectureIdAndLangMedia(int lectureId, String langMedia);

  @Query("SELECT vocables.* FROM vocables LEFT JOIN lectures ON vocables.lecture_id = lectures.id "
      "WHERE pack = :lecturePack AND lang_media = :langMedia ORDER BY vocable_sort ASC")
  Future<List<Vocable>> findVocablesByLecturePackAndLangMedia(String lecturePack, String langMedia);

  @Query("SELECT * FROM vocables WHERE lecture_id = :lectureId ORDER BY vocable_sort ASC")
  Future<List<Vocable>> findVocablesByLectureId(int lectureId);

  @insert
  Future<List<int>> insertVocables(List<Vocable> vocables);

  @update
  Future<void> updateVocable(Vocable vocable);

  @update
  Future<void> updateVocables(List<Vocable> vocables);

  @Query("DELETE FROM vocables WHERE lecture_id = :lectureId")
  Future<void> deleteVocablesByLectureId(int lectureId);

  @Query("DELETE FROM vocables")
  Future<void> deleteAllVocables();

  @Query("UPDATE vocables SET vocable_progress = 0")
  Future<void> resetAllVocableProgress();
}