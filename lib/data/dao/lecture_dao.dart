import 'package:floor/floor.dart';
import 'package:lectary/data/entities/lecture.dart';

@dao
abstract class LectureDao {

  @Query("SELECT * FROM lectures")
  Stream<List<Lecture>> findAllLectures();

  @insert
  Future<void> insertLecture(Lecture lecture);

  @update
  Future<void> updateLecture(Lecture lecture);

  @delete
  Future<void> deleteLecture(Lecture lecture);
}