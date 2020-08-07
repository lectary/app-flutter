// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/db/entities/coding.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/abstract_dao.dart';
import 'dao/coding_dao.dart';
import 'dao/lecture_dao.dart';
import 'dao/vocable_dao.dart';
import 'entities/lecture.dart';
import 'entities/vocable.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Lecture, Vocable, Abstract, Coding, CodingEntry])
abstract class LectureDatabase extends FloorDatabase {
  LectureDao get lectureDao;
  VocableDao get vocableDao;
  AbstractDao get abstractDao;
  CodingDao get codingDao;
}

class DatabaseProvider {
  static final _instance = DatabaseProvider._internal();
  static DatabaseProvider instance = _instance;

  DatabaseProvider._internal();

  static LectureDatabase _db;

  Future<LectureDatabase> get db async {
    if (_db == null) {
      _db = await $FloorLectureDatabase.databaseBuilder('lectures.db')
          .addCallback(callback)
          .build();
    }
    return _db;
  }

  Future<void> closeDB() async {
    if (_db != null) {
      _db.close();
    }
  }

  /// insert mock data
  final callback = Callback(onOpen: (database) {
    //database.delete("vocables");
    //database.delete("lectures");
    final lectures = List<Map<String, dynamic>>.of({
      {
        "file_name":
            "PACK--Alpen__Adria__Universit_aet---LESSON--AAU__Lektion__4---LANG--OGS-DE---SORT--104---DATE--2019-04-29.zip",
        "file_size": 5,
        "vocable_count": 5,
        "pack": "Alpen Adria Universität",
        "lesson": "AAU Lektion 4",
        "date": "2019-04-29",
        "lang": "test"
      },
      {
        "file_name":
            "PACK--Alpen__Adria__Universit_aet---LESSON--AAU__Lektion__5---LANG--OGS-DE---SORT--105---DATE--2019-04-29.zip",
        "file_size": 5,
        "vocable_count": 5,
        "pack": "Alpen Adria Universität",
        "lesson": "AAU Lektion 5",
        "date": "2019-04-30",
        "lang": "test"
      },
      {
        "file_name":
            "PACK--Alpen__Adria__Universit_aet---LESSON--TEST---LANG--OGS-DE---SORT--105---DATE--2019-04-29.zip",
        "file_size": 5,
        "vocable_count": 5,
        "pack": "Alpen Adria Universität",
        "lesson": "TEST",
        "date": "2019-04-29",
        "lang": "test"
      },
    });

    lectures.forEach((lecture) {
      //database.insert("lectures", lecture);
    });
  });
}