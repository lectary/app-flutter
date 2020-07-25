// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/lecture_dao.dart';
import 'entities/lecture.dart';
import 'entities/vocable.dart';


part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Lecture, Vocable])
abstract class LectureDatabase extends FloorDatabase {
  LectureDao get lectureDao;
}