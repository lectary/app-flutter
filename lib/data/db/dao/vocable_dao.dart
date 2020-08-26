import 'package:floor/floor.dart';
import 'package:lectary/data/db/entities/vocable.dart';

@dao
abstract class VocableDao {

  @Query("SELECT * FROM vocables ORDER BY vocable_sort ASC")
  Future<List<Vocable>> findAllVocables();

  @Query("SELECT * FROM vocables WHERE lecture_id = :lectureId ORDER BY vocable_sort ASC")
  Future<List<Vocable>> findVocablesByLectureId(int lectureId);

  @Query("SELECT vocables.* FROM vocables LEFT JOIN lectures ON vocables.lecture_id = lectures.id WHERE pack = :lecturePack ORDER BY vocable_sort ASC")
  Future<List<Vocable>> findVocablesByLecturePack(String lecturePack);

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