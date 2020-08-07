import 'package:floor/floor.dart';
import 'package:lectary/data/db/entities/lecture.dart';

@dao
abstract class LectureDao {

  @Query("SELECT * FROM lectures")
  Stream<List<Lecture>> watchAllLectures();

  @Query("SELECT * FROM lectures")
  Future<List<Lecture>> findAllLectures();

  @Query("SELECT * FROM lectures WHERE lang_vocable = :lang")
  Future<List<Lecture>> findAllLecturesWithLang(String lang);

  @insert
  Future<int> insertLecture(Lecture lecture);

  @update
  Future<void> updateLecture(Lecture lecture);

  @delete
  Future<void> deleteLecture(Lecture lecture);

  @Query("DELETE FROM lectures")
  Future<void> deleteAllLectures();
}