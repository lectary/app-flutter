import 'dart:io';

import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:test/test.dart';

import 'package:mockito/mockito.dart';

class MockLectureRepository extends Mock implements LectureRepository {}

void main() {
  group('Testing status handling of "mergeAndCheckCodings" |', () {
    LectureViewModel lectureViewModel = LectureViewModel(lectureRepository: MockLectureRepository());
    test('should set status to "notPersisted"', () {
      List<Coding> localList = List();
      List<Coding> remoteList = List.of({
        Coding(
            fileName: "CODING--CZ---DATE--2020-05-26.json",
            lang: "CZ",
            date: "2020-06-21"
        )
      });

      List<Coding> mergedCodings = lectureViewModel.mergeAndCheckCodings(localList, remoteList);
      expect(mergedCodings[0].codingStatus, CodingStatus.notPersisted);
    });
    test('should set status to "updateAvailable"', () {
      List<Coding> localList = List.of({
        Coding(
            fileName: "CODING--CZ---DATE--2020-05-26.json",
            lang: "CZ",
            date: "2020-06-20"
        )
      });
      List<Coding> remoteList = List.of({
        Coding(
            fileName: "CODING--CZ---DATE--2020-05-26.json",
            lang: "CZ",
            date: "2020-06-21"
        )
      });

      List<Coding> mergedCodings = lectureViewModel.mergeAndCheckCodings(localList, remoteList);
      expect(mergedCodings[0].codingStatus, CodingStatus.updateAvailable);
    });
    test('should set status to "removed"', () {
      List<Coding> localList = List.of({
        Coding(
            fileName: "CODING--CZ---DATE--2020-05-26.json",
            lang: "CZ",
            date: "2020-06-21"
        )
      });
      List<Coding> remoteList = List();

      List<Coding> mergedCodings = lectureViewModel.mergeAndCheckCodings(localList, remoteList);
      expect(mergedCodings[0].codingStatus, CodingStatus.removed);
    });
  });

  group('Correct coding file json extraction', () {
    LectureViewModel lectureViewModel = LectureViewModel(lectureRepository: MockLectureRepository());
    test('testing replacing of unescaped characters', () {
      String fileContent = '[\n{\n\"char\": "¿",\n\"asciify\": "_ESQM"\n},\n{\n\"char\": "¡",\n\"asciify\": "_ESRR"\n}\n]';
      File jsonFile = File('test/codingTest.json');
      jsonFile.createSync();
      jsonFile.writeAsStringSync(fileContent);
      List<CodingEntry> output = lectureViewModel.extractCodingEntries(jsonFile);
      jsonFile.deleteSync();

      List<CodingEntry> expectedEntries = List.of({
        CodingEntry(
            char: "¿",
            ascii: "_ESQM"
        ),
        CodingEntry(
            char: "¡",
            ascii: "_ESRR"
        )
      });

      expect(output.toString(), expectedEntries.toString());
    });
  });
}