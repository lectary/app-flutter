import 'package:floor/floor.dart';
import 'package:lectary/data/entities/vocable.dart';

@dao
abstract class VocableDao {

  @Query("SELECT * FROM vocables")
  Future<List<Vocable>> findAllVocables();

  @Query("SELECT * FROM vocables WHERE lecture_id = :lectureId")
  Future<List<Vocable>> findVocablesByLectureId(int lectureId);

  @Query("SELECT * FROM vocables JOIN lectures ON vocables.lecture_id = lectures.id WHERE pack = :lecturePack")
  Future<List<Vocable>> findVocablesByLecturePack(String lecturePack);

  @insert
  Future<List<int>> insertVocables(List<Vocable> vocables);

  @update
  Future<void> updateVocable(Vocable vocable);

  @Query("DELETE FROM vocables WHERE lecture_id = :lectureId")
  Future<void> deleteVocablesByLectureId(int lectureId);

  @Query("DELETE FROM vocables")
  Future<void> deleteAllVocables();
}