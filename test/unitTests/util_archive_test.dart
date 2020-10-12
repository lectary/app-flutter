import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:lectary/utils/exceptions/archive_structure_exception.dart';
import 'package:lectary/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  final testDirPath = 'test' + '/' + 'archive-test-data';
  final baseDir = 'lecture-pack';

  group('Archive validation tests |', () {

    tearDown(() async {
      try {
        Directory(testDirPath).deleteSync(recursive: true);
      } catch(e) {
        print(e);
      }
    });

    test('Test1 - should be successful', () {
      Directory validDir = Directory(testDirPath + '/' + baseDir);
      validDir.createSync(recursive: true);
      File(testDirPath + '/' + baseDir + '/' + 'text.txt').createSync();
      File(testDirPath + '/' + baseDir + '/' + 'video.mp4').createSync();
      File(testDirPath + '/' + baseDir + '/' + 'image.png').createSync();
      File(testDirPath + '/' + baseDir + '/' + 'image.jpg').createSync();


      var encoder = ZipFileEncoder();
      encoder.create(testDirPath + '/' + baseDir + '.zip');
      encoder.addDirectory(validDir, includeDirName: true);
      encoder.close();

      File zipFile = File(testDirPath + '/' + baseDir + '.zip');
      Archive archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());

      expect(Utils.validateArchive(zipFile, archive), isTrue);
    });

    test('Test2 - should throw exception due to wrong media type', () {
      Directory invalidDirWrongType = Directory(testDirPath + '/' + baseDir);
      invalidDirWrongType.createSync(recursive: true);
      File(testDirPath + '/' + baseDir + '/' + 'text.txt').createSync();
      File(testDirPath + '/' + baseDir + '/' +  'rndType.random').createSync();

      var encoder = ZipFileEncoder();
      encoder.create(testDirPath + '/' + baseDir + '.zip');
      encoder.addDirectory(invalidDirWrongType, includeDirName: true);
      encoder.close();

      File zipFile = File(testDirPath + '/' + baseDir + '.zip');
      Archive archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());

      try {
        Utils.validateArchive(zipFile, archive);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, TypeMatcher<ArchiveStructureException>());
        expect(e.toString(), contains("Type is not supported"));
      }
    });

    test('Test3 - should throw exception due to missing inner directory', () {
      File textFile = File(testDirPath + '/' + 'text.txt');
      textFile.createSync(recursive: true);

      var encoder = ZipFileEncoder();
      encoder.create(testDirPath + '/' + baseDir + '.zip');
      encoder.addFile(textFile);
      encoder.close();

      File zipFile = File(testDirPath + '/' + baseDir + '.zip');
      Archive archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());

      try {
        Utils.validateArchive(zipFile, archive);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, TypeMatcher<ArchiveStructureException>());
        expect(e.toString(), contains("Inner directory name should be equal the archive name"));
      }
    });

    test('Test4 - should throw exception due to invalid nested directories', () {
      Directory invalidDirNestedDir = Directory(testDirPath + '/' + baseDir);
      invalidDirNestedDir.createSync(recursive: true);
      File(testDirPath + '/' + baseDir + '/' + 'text.txt').createSync();

      final String child = 'childDir';
      Directory childDir = Directory(testDirPath + '/' + baseDir + '/' + child);
      childDir.createSync(recursive: true);
      File(testDirPath + '/' + baseDir + '/' + child + '/' + 'text.txt').createSync();

      var encoder = ZipFileEncoder();
      encoder.create(testDirPath + '/' + baseDir + '.zip');
      encoder.addDirectory(invalidDirNestedDir, includeDirName: true);
      encoder.close();

      File zipFile = File(testDirPath + '/' + baseDir + '.zip');
      Archive archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());

      try {
        Utils.validateArchive(zipFile, archive);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, TypeMatcher<ArchiveStructureException>());
        expect(e.toString(), contains("Wrong archive structure"));
      }
    });

    test('Test5 - should throw exception due to mismatch in filename of archive and inner directory', () {
      final String wrongDirName = 'wrong-dir-name';
      Directory invalidDirWrongName = Directory(testDirPath + '/' + wrongDirName);
      invalidDirWrongName.createSync(recursive: true);
      File(testDirPath + '/' + wrongDirName + '/' + 'text.txt').createSync();

      var encoder = ZipFileEncoder();
      encoder.create(testDirPath + '/' + baseDir + '.zip');
      encoder.addDirectory(invalidDirWrongName, includeDirName: true);
      encoder.close();

      File zipFile = File(testDirPath + '/' + baseDir + '.zip');
      Archive archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());

      try {
        Utils.validateArchive(zipFile, archive);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, TypeMatcher<ArchiveStructureException>());
        expect(e.toString(), contains("Inner directory name should be equal"));
      }
    });

    test('Test6 - should throw exception due file without a filename', () {
      final String dirName = 'dir-name';
      Directory invalidDirWrongName = Directory(testDirPath + '/' + dirName);
      invalidDirWrongName.createSync(recursive: true);
      File(testDirPath + '/' + dirName + '/' + '.txt').createSync();

      var encoder = ZipFileEncoder();
      encoder.create(testDirPath + '/' + baseDir + '.zip');
      encoder.addDirectory(invalidDirWrongName, includeDirName: true);
      encoder.close();

      File zipFile = File(testDirPath + '/' + baseDir + '.zip');
      Archive archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());

      try {
        Utils.validateArchive(zipFile, archive);
        fail("should had thrown exception");
      } catch(e) {
        expect(e, TypeMatcher<ArchiveStructureException>());
        expect(e.toString(), contains("File without fileName found"));
      }
    });
  });
}