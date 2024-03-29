import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/utils/exceptions/lecture_exception.dart';
import 'package:lectary/utils/exceptions/media_type_exception.dart';
import 'package:lectary/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group('extracting lecture metadata', () {
    test('Test1 - successful extraction', () {
      String zipFile = "PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS-DE---DATE--2020-03-03.zip";
      Map<String, dynamic> metaInfos = Lecture.extractMetadata(zipFile);

      Map<String, dynamic> expectedMap = Map.of({
        "PACK": "Testung",
        "LESSON": "Ölfarben",
        "LESSON-SORT": "ozzzzlfarben",
        "LANG-MEDIA": "ÖGS",
        "LANG-VOCABLE": "DE",
        "DATE": "2020-03-03",
      });
      expect(metaInfos, expectedMap);
    });

    test('Test2 - successful extraction with malformed fileName with quad "-"', () {
      String zipFile = "PACK--Testung----LESSON--_Oelfarben----LANG--_OeGS-DE---DATE--2020-03-03.zip";
      Map<String, dynamic> metaInfos = Lecture.extractMetadata(zipFile);

      Map<String, dynamic> expectedMap = Map.of({
        "PACK": "Testung",
        "LESSON": "Ölfarben",
        "LESSON-SORT": "ozzzzlfarben",
        "LANG-MEDIA": "ÖGS",
        "LANG-VOCABLE": "DE",
        "DATE": "2020-03-03",
      });
      expect(metaInfos, expectedMap);
    });

    test('Test3 - successful extraction with malformed fileName without "---"', () {
      String zipFile = "PACK--Testung--LESSON--_Oelfarben--LANG--_OeGS-DE--DATE--2020-03-03.zip";
      Map<String, dynamic> metaInfos = Lecture.extractMetadata(zipFile);

      Map<String, dynamic> expectedMap = Map.of({
        "PACK": "Testung",
        "LESSON": "Ölfarben",
        "LESSON-SORT": "ozzzzlfarben",
        "LANG-MEDIA": "ÖGS",
        "LANG-VOCABLE": "DE",
        "DATE": "2020-03-03",
      });
      expect(metaInfos, expectedMap);
    });

    test('Test4 - missing zip ending', () {
      String zipFile = "PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS-DE---DATE--2020-03-03";
      try {
        Lecture.extractMetadata(zipFile);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, const TypeMatcher<LectureException>());
        expect(e.toString(), contains("Missing .zip"));
      }
    });

    test('Test5 - missing mandatory meta info', () {
      String zipFile1 = "LESSON--_Oelfarben---LANG--_OeGS-DE---DATE--2020-03-03.zip";
      try {
        Lecture.extractMetadata(zipFile1);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, const TypeMatcher<LectureException>());
        expect(e.toString(), contains("Missing: PACK"));
      }
      String zipFile2 = "PACK--Testung---LANG--_OeGS-DE---DATE--2020-03-03.zip";
      try {
        Lecture.extractMetadata(zipFile2);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, const TypeMatcher<LectureException>());
        expect(e.toString(), contains("Missing: LESSON"));
      }
      String zipFile3 = "PACK--Testung---LESSON--_Oelfarben---DATE--2020-03-03.zip";
      try {
        Lecture.extractMetadata(zipFile3);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, const TypeMatcher<LectureException>());
        expect(e.toString(), contains("Missing: LANG"));
      }
    });

    test('Test6 - malformed lang with only one language', () {
      String zipFile = "PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS---DATE--2020-03-03.zip";
      try {
        Lecture.extractMetadata(zipFile);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, const TypeMatcher<LectureException>());
        expect(e.toString(), contains("Malformed LANG"));
      }
    });

    test('Test7 - malformed lang with invalid separator', () {
      String zipFile = "PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS+DE---DATE--2020-03-03.zip";
      try {
        Lecture.extractMetadata(zipFile);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, const TypeMatcher<LectureException>());
        expect(e.toString(), contains("Malformed LANG"));
      }
    });

    test('Test8 - malformed date format', () {
      String zipFile = "PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS-DE---DATE--2020-3-03.zip";
      try {
        Lecture.extractMetadata(zipFile);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, const TypeMatcher<LectureException>());
        expect(e.toString(), contains("Malformed DATE"));
      }
    });

    test('Test9 - leading "---" should be filtered', () {
      String zipFile = "---PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS-DE---DATE--2020-03-03.zip";
      Map<String, dynamic> resultMap = Lecture.extractMetadata(zipFile);
      Map<String, dynamic> expectedMap = Map.of({
        "PACK": "Testung",
        "LESSON": "Ölfarben",
        "LESSON-SORT": "ozzzzlfarben",
        "LANG-MEDIA": "ÖGS",
        "LANG-VOCABLE": "DE",
        "DATE": "2020-03-03",
      });
      expect(resultMap, expectedMap);
    });

    test('Test10 - malformed mandatory metadata - keys merged together', () {
      String zipFile = "PACKLESSONLANG--Testung---T--_Oelfarben---T--_OeGS-DE---DATE--2020-03-03.zip";
      try {
        Lecture.extractMetadata(zipFile);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, const TypeMatcher<LectureException>());
        expect(e.toString(), contains("Lecture has not mandatory metadata"));
      }
    });
  });

  group('extracting filename of filepath |', () {
    test('Test1 - successful extraction with slash as path separator', () {
      String zipFile = "test1.com/test2/fileName.zip";
      String dirName = Utils.extractFileName(zipFile);
      expect(dirName, "fileName");
    });

    test('Test2 - successful extraction with backslash as path separator ', () {
      String zipFile = "test1.com\\test2\\fileName.zip";
      String dirName = Utils.extractFileName(zipFile);
      expect(dirName, "fileName");
    });

    test('Test3 - successful extraction with slash and backslash as path separator', () {
      String zipFile = "test1.com\\test2/fileName.zip";
      String dirName = Utils.extractFileName(zipFile);
      expect(dirName, "fileName");
    });

    test('Test4 - filename without extension', () {
      String filename = "withoutExtension";
      String extractedName = Utils.extractFileName(filename);
      expect(extractedName, "withoutExtension");
    });

    test('Test5 - empty string should return empty string', () {
      String filename = "";
      String extractedName = Utils.extractFileName(filename);
      expect(extractedName, "");
    });
  });

  group('extracting directory name of filepath |', () {
    test('Test1 - successful extraction with slash as path separator', () {
      String fileName = "/test.com/dirName/file.mp4";
      String dirName = Utils.extractDirName(fileName);
      expect(dirName, "dirName");
    });

    test('Test2 - successful extraction with backslash as path separator', () {
      String fileName = "\\test.com\\dirName\\file.mp4";
      String dirName = Utils.extractDirName(fileName);
      expect(dirName, "dirName");
    });

    test('Test3 - successful extraction with slash and backslash as path separator', () {
      String fileName = "\\test.com/dirName\\file.mp4";
      String dirName = Utils.extractDirName(fileName);
      expect(dirName, "dirName");
    });

    test('Test4 - filename without extension', () {
      String filename = "withoutDirectory";
      String extractedDirName = Utils.extractDirName(filename);
      expect(extractedDirName, "");
    });

    test('Test5 - empty string should return empty string', () {
      String filename = "";
      String extractedDirName = Utils.extractDirName(filename);
      expect(extractedDirName, "");
    });

    test('Test6 - successful on filenames with only one path separator', () {
      String filename = "dir1/file.random";
      String extractedDirName = Utils.extractDirName(filename);
      expect(extractedDirName, "dir1");
    });
  });

  group('Date extraction util | ', () {
    test('Test1 - successful extraction of date meta info', () {
      String lectureFileName = "PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS-DE---DATE--2020-03-03.zip";
      String newDate = Utils.extractDateMetadatumFromFileName(lectureFileName);
      expect(newDate, "2020-03-03");
    });

    test('Test2 - return empty string on missing date meta info', () {
      String lectureFileName = "PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS-DE.zip";
      String newDate = Utils.extractDateMetadatumFromFileName(lectureFileName);
      expect(newDate, "");
    });

    test('Test3 - return empty string on invalid filename', () {
      String lectureFileName = "randomString";
      String newDate = Utils.extractDateMetadatumFromFileName(lectureFileName);
      expect(newDate, "");
    });

    test('Test4 - return empty string on invalid filename but with file extension', () {
      String lectureFileName = ".zip";
      String newDate = Utils.extractDateMetadatumFromFileName(lectureFileName);
      expect(newDate, "");
    });

    test('Test5 - return empty string on invalid filename with malformed date info', () {
      String lectureFileName = "PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS-DE---DATE-2020-03-03.zip";
      String newDate = Utils.extractDateMetadatumFromFileName(lectureFileName);
      expect(newDate, "");
    });

    test('Test6 - return empty string on invalid filename with malformed meta info separation', () {
      String lectureFileName = "PACK--Testung---LESSON--_Oelfarben---LANG--_OeGS-DE--DATE--2020-03-03.zip";
      String newDate = Utils.extractDateMetadatumFromFileName(lectureFileName);
      expect(newDate, "");
    });
  });

  group('ExtractingFileExtension', () {
    test('Test1 - file extension should get extracted out of full filename', () {
      String fileName = "test1.com/test2/file.mp4";
      String extension = Utils.extractFileExtension(fileName);
      expect(extension, "mp4");
    });

    test('Test2 - should return empty string with a path without a file', () {
      String fileName = "test1/test2/";
      String extension = Utils.extractFileExtension(fileName);
      expect(extension, "");
    });

    test('Test3 - should return empty string with a path without a file but with a dot', () {
      String fileName = "test1.com/test2/";
      String extension = Utils.extractFileExtension(fileName);
      expect(extension, "");
    });
  });

  group('MediaType conversion |', () {
    test('should success with mp4 png jpg or txt and should work case insensitive', () {
      MediaType type1 = MediaType.fromString("mp4");
      expect(type1, MediaType.mp4);
      MediaType type2 = MediaType.fromString("png");
      expect(type2, MediaType.png);
      MediaType type3 = MediaType.fromString("JPG");
      expect(type3, MediaType.jpg);
      MediaType type4 = MediaType.fromString("TXT");
      expect(type4, MediaType.txt);
    });

    test('should throw an exception on unknown extension/type', () {
      expect(() => MediaType.fromString("UNKNOWN"), throwsA(const TypeMatcher<MediaTypeException>()));
    });
  });

  test('method currentDate should print current date in ISO-8601 format yyyy-MM-dd', () {
    String currentDate = Utils.currentDate();

    expect(currentDate, ""
        "${DateTime.now().year}"
        "-${DateTime.now().month < 10 ? "0${DateTime.now().month}" : DateTime.now().month}"
        "-${DateTime.now().day < 10 ? "0${DateTime.now().day}" : DateTime.now().day}");
  });

  test('method fillWithLeadingZeros should fill string with leading zeros up to a length of 5', () {
    String sort1 = "1";
    String sort2 = "01";
    String sort3 = "001";
    String sort4 = "0001";
    String sort5 = "00001";

    sort1 = Utils.fillWithLeadingZeros(sort1);
    sort2 = Utils.fillWithLeadingZeros(sort2);
    sort3 = Utils.fillWithLeadingZeros(sort3);
    sort4 = Utils.fillWithLeadingZeros(sort4);
    sort5 = Utils.fillWithLeadingZeros(sort5);

    expect(sort1, "00001");
    expect(sort2, "00001");
    expect(sort3, "00001");
    expect(sort4, "00001");
    expect(sort5, "00001");
  });

  test('Sorting Test', () {
    String string1 = "Azzuri";
    String string2 = "Ä";
    String string3 = "St.Pölten";
    String string4 = "Sankt";
    String string5 = "Ozeanaut";
    String string6 = "ö";
    String string7 = "ss";
    String string8 = "ß";

    List<String> listToSort = List.of({
      string6,
      string5,
      string1,
      string8,
      string4,
      string3,
      string7,
      string2
    });
    List<String> sortedList = List.of({
      string1,
      string2,
      string5,
      string6,
      string4,
      string3,
      string7,
      string8,
    });

    listToSort.sort((a, b) => Utils.customCompareTo(a, b));

    expect(listToSort.toString(), sortedList.toString());
  });
}