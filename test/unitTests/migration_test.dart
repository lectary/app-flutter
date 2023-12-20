import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lectary/data/db/database.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:test/test.dart';

void main() {
  group('test database migrations', () {
    test('vocable filePath update', () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Examples:
      // "/data/user/0/com.ionicframework.lectary.debug/app_flutter/PACK--Alpen__Adria__Universit_aet---LESSON--AAU__Lektion__3---LANG--_OeGS-DE---SORT--103---DATE--2020-11-14/Aussehen.mp4";
      // "/PACK--Alpen__Adria__Universit_aet---LESSON--AAU__Lektion__3---LANG--_OeGS-DE---SORT--103---DATE--2020-11-14/Aussehen.mp4";

      final floorDb = await DatabaseProvider.getTestDb();

      final appDir = "someRandomAppDir${Random().nextInt(1000)}";

      final lecture = Lecture(fileName: "lectureA", fileSize: 10, vocableCount: 10, pack: "superDuperPack", lesson: "superDuperLesson", lessonSort: "1", langMedia: "de", langVocable: "de", date: DateTime.now().toIso8601String());
      final lectureId = await floorDb.lectureDao.insertLecture(lecture);

      final vocableA = Vocable(lectureId: lectureId, vocable: "vocableA", vocableSort: "100", mediaType: MediaType.mp4.name, media: "$appDir/lectureFileName/vocableA.${MediaType.mp4.name}");
      final vocableB = Vocable(lectureId: lectureId, vocable: "vocableB", vocableSort: "101", mediaType: MediaType.mp4.name, media: "$appDir/lectureFileName/vocableB.${MediaType.mp4.name}");
      await floorDb.vocableDao.insertVocables(List.of({vocableA, vocableB}));

      await migration1To2.migrate.call(floorDb.database.database);

      final updatedVocables = await floorDb.vocableDao.findVocablesByLectureId(lectureId);
      for (final vocable in updatedVocables) {
        expect(vocable.media, predicate((String filePath) => !filePath.contains(appDir)));
      }
    });
  });
}
