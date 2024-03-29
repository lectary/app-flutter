import 'dart:io';

import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../shared_mocks.mocks.dart';

@GenerateMocks([LectureRepository])
void main() async {
  Coding coding = Coding(id: 1, fileName: "CODING--CZ---DATE--2020-05-26.json", lang: "CZ", date: "2020-05-26");
  coding.codingStatus = CodingStatus.updateAvailable;
  coding.fileNameUpdate = "CODING--CZ---DATE--2020-05-27.json";

  List<Lecture> persistedLecturesWithLangCZ = List.of({
    Lecture(
        id: 1,
        fileName: "",
        fileSize: 5,
        vocableCount: 5,
        pack: "",
        lesson: "",
        lessonSort: "",
        langVocable: "CZ",
        langMedia: "DE",
        date: '2021-04-04'),
    Lecture(
        id: 2,
        fileName: "",
        fileSize: 5,
        vocableCount: 5,
        pack: "",
        lesson: "",
        lessonSort: "",
        langVocable: "CZ",
        langMedia: "DE",
        date: '2021-04-04')
  });

  List<Vocable> persistedVocablesLectureId1 = List.of({
    Vocable(lectureId: 1, vocable: "_CZXA", vocableSort: "", media: "", mediaType: ""),
    Vocable(lectureId: 1, vocable: "_CZd", vocableSort: "", media: "", mediaType: ""),
  });
  List<Vocable> persistedVocablesLectureId2 =
      List.of({Vocable(lectureId: 2, vocable: "_CZC", vocableSort: "", media: "", mediaType: "")});

  List<Vocable> updatedVocables = List.of({
    Vocable(lectureId: 1, vocable: "Á", vocableSort: "", media: "", mediaType: ""),
    Vocable(lectureId: 1, vocable: "ď", vocableSort: "", media: "", mediaType: ""),
    Vocable(lectureId: 2, vocable: "Č", vocableSort: "", media: "", mediaType: "")
  });

  group('Integration testing of coding |', () {
    final mockRepo = MockLectureRepository();
    LectureViewModel lectureViewModel = LectureViewModel(lectureRepository: mockRepo);

    File file = File('test/${coding.fileName}');
    String fileContent =
        "[{\"char\": \"Á\",\"asciify\": \"_CZXA\"},{\"char\": \"á\",\"asciify\": \"_CZXa\"}, {\"char\": \"Č\",\"asciify\": \"_CZC\"},{\"char\": \"č\",\"asciify\": \"_CZc\"},{\"char\": \"Ď\",\"asciify\": \"_CZD\"},{\"char\": \"ď\",\"asciify\": \"_CZd\"},{\"char\": \"É\",\"asciify\": \"_CZXE\"},{\"char\": \"é\",\"asciify\": \"_CZXe\"},{\"char\": \"Ě\",\"asciify\": \"_CZE\"},{\"char\": \"é\",\"asciify\": \"_CZe\"},{\"char\": \"Í\",\"asciify\": \"_CZXI\"},{\"char\": \"í\",\"asciify\": \"_CZXi\"},{\"char\": \"Ň\",\"asciify\": \"_CZN\"},{\"char\": \"ň\",\"asciify\": \"_CZn\"},{\"char\": \"Ó\",\"asciify\": \"_CZXO\"},{\"char\": \"ó\",\"asciify\": \"_CZXo\"},{\"char\": \"Ř\",\"asciify\": \"_CZR\"},{\"char\": \"ř\",\"asciify\": \"_CZr\"},{\"char\": \"Š\",\"asciify\": \"_CZS\"},{\"char\": \"š\",\"asciify\": \"_CZs\"},{\"char\": \"Ť\",\"asciify\": \"_CZT\"},{\"char\": \"ť\",\"asciify\": \"_CZt\"},{\"char\": \"Ú\",\"asciify\": \"_CZXU\"},{\"char\": \"ú\",\"asciify\": \"_CZXu\"},{\"char\": \"Ů\",\"asciify\": \"_CZU\"},{\"char\": \"ů\",\"asciify\": \"_CZu\"},{\"char\": \"Ý\",\"asciify\": \"_CZXY\"},{\"char\": \"ý\",\"asciify\": \"_CZXy\"},{\"char\": \"Ž\",\"asciify\": \"_CZZ\"},{\"char\": \"ž\",\"asciify\": \"_CZz\"}]";
    file.writeAsStringSync(fileContent);

    test('Test1 - updating coding updates vocables with corresponding lang', () async {
      when(mockRepo.downloadCoding(coding)).thenAnswer((_) async => Future.value(file));
      when(mockRepo.findAllLecturesWithLang(coding.lang))
          .thenAnswer((_) async => Future.value(persistedLecturesWithLangCZ));
      when(mockRepo.findVocablesByLectureId(1)).thenAnswer((_) async => Future.value(persistedVocablesLectureId1));
      when(mockRepo.findVocablesByLectureId(2)).thenAnswer((_) async => Future.value(persistedVocablesLectureId2));

      try {
        await lectureViewModel.updateCoding(coding);
        expect(verify(mockRepo.updateVocables(captureAny)).captured.single.toString(), updatedVocables.toString());
      } finally {
        file.deleteSync();
      }
    });
  });
}
