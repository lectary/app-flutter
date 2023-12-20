import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
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
@Database(version: 2, entities: [Lecture, Vocable, Abstract, Coding, CodingEntry])
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
    _db ??= await $FloorLectureDatabase
        .databaseBuilder(Constants.databaseName)
        .addMigrations([migration1To2])
        .build();
    return _db!;
  }

  @visibleForTesting
  static Future<LectureDatabase> getTestDb() async {
    _db ??= await $FloorLectureDatabase.inMemoryDatabaseBuilder().build();
    return _db!;
  }

  Future<void> closeDB() async {
    if (_db != null) {
      _db!.close();
    }
  }
}

final migration1To2 = Migration(1, 2, (db) async {
  log("Start DB migration from 1 to 2");

  await db.transaction((txn) async {
    final batch = txn.batch();

    final vocables = await txn.query('vocables');
    for (final Map<String, Object?> current in vocables) {
      final id = current['id']!;
      final String oldPath = current['media']! as String;

      // update path
      final splits = oldPath.split("/");
      final newMediaPath = "${splits[splits.length - 2]}${Platform.pathSeparator}${splits[splits.length - 1]}";

      // get a mutable map from sqflites immutable one
      final Map<String, Object?> newVocable = Map.from(current);
      newVocable['media'] = newMediaPath;

      batch.update("vocables", newVocable, where: 'id = ?', whereArgs: [id]);
    }

    await batch.commit();
  });

  log("Finished DB migration from 1 to 2");
});
