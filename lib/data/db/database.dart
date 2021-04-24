import 'dart:async';
import 'package:floor/floor.dart';
import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/utils/constants.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/abstract_dao.dart';
import 'dao/coding_dao.dart';
import 'dao/lecture_dao.dart';
import 'dao/vocable_dao.dart';
import 'entities/lecture.dart';
import 'entities/vocable.dart';

part 'database.g.dart'; // the generated code will be there


/// Abstract database, whose functionality is generated via the floor generator.
@Database(version: 1, entities: [Lecture, Vocable, Abstract, Coding, CodingEntry])
abstract class LectureDatabase extends FloorDatabase {
  LectureDao get lectureDao;
  VocableDao get vocableDao;
  AbstractDao get abstractDao;
  CodingDao get codingDao;
}


/// Database helper class for creating an instance of the [LectureDatabase] as singleton.
class DatabaseProvider {
  static final _instance = DatabaseProvider._internal();
  static DatabaseProvider instance = _instance;

  DatabaseProvider._internal();

  static LectureDatabase? _db;

  Future<LectureDatabase> get db async {
    if (_db == null) {
      _db = await $FloorLectureDatabase.databaseBuilder(Constants.databaseName)
          .build();
    }
    return _db!;
  }

  Future<void> closeDB() async {
    if (_db != null) {
      _db!.close();
    }
  }
}