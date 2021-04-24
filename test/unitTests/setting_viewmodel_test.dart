import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lectary_overview.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../shared_mocks.mocks.dart';

@GenerateMocks([LectureRepository])
void main() async {
  group('Tests for SettingViewModel', () {
    group('Group 1 - Testing behaviour of updating of learning languages', () {
      test('Test 1 - a local language, that is not in the remote list, appears in the result list', () async {
        List<Lecture> localLectures = List.of({
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "ÖGS",
              date: '2021-04-04'),
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "DGS",
              date: '2021-04-04')
        });
        List<Lecture> remoteLectures = List.of({
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "ÖGS",
              date: '2021-04-04'),
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "ES",
              date: '2021-04-04')
        });
        LectaryData lectaryData = LectaryData(lessons: remoteLectures, codings: [], abstracts: []);

        SharedPreferences.setMockInitialValues({});

        final mockRepo = MockLectureRepository();
        when(mockRepo.loadLectaryData()).thenAnswer((_) async => Future.value(lectaryData));
        when(mockRepo.loadLecturesLocal()).thenAnswer((_) async => Future.value(localLectures));

        SettingViewModel settingViewModel = SettingViewModel(lectureRepository: mockRepo);
        await settingViewModel.updateLearningLanguages();

        List<String> resultLangs = settingViewModel.learningLanguagesList;
        List<String> correctList = List.of({'ÖGS', 'DGS', 'ES'});
        expect(resultLangs, containsAll(correctList));
      });

      test('Test 2 - with empty local list, only the remote list appears in the result list', () async {
        List<Lecture> localLectures = List.of({});
        List<Lecture> remoteLectures = List.of({
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "ÖGS",
              date: '2021-04-04'),
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "ES",
              date: '2021-04-04'),
        });
        LectaryData lectaryData = LectaryData(lessons: remoteLectures, abstracts: [], codings: []);

        SharedPreferences.setMockInitialValues({});

        final mockRepo = MockLectureRepository();
        when(mockRepo.loadLectaryData()).thenAnswer((_) async => Future.value(lectaryData));
        when(mockRepo.loadLecturesLocal()).thenAnswer((_) async => Future.value(localLectures));

        SettingViewModel settingViewModel = SettingViewModel(lectureRepository: mockRepo);
        await settingViewModel.updateLearningLanguages();

        List<String> resultLangs = settingViewModel.learningLanguagesList;
        List<String> correctList = List.of({'ÖGS', 'ES'});
        expect(resultLangs, containsAll(correctList));
      });

      test('Test 3 - with empty remote list, only the local list appears in the result list', () async {
        List<Lecture> localLectures = List.of({
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "ÖGS",
              date: '2021-04-04'),
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "ES",
              date: '2021-04-04'),
        });
        List<Lecture> remoteLectures = List.of({});
        LectaryData lectaryData = LectaryData(lessons: remoteLectures, abstracts: [], codings: []);

        SharedPreferences.setMockInitialValues({});

        final mockRepo = MockLectureRepository();
        when(mockRepo.loadLectaryData()).thenAnswer((_) async => Future.value(lectaryData));
        when(mockRepo.loadLecturesLocal()).thenAnswer((_) async => Future.value(localLectures));

        SettingViewModel settingViewModel = SettingViewModel(lectureRepository: mockRepo);
        await settingViewModel.updateLearningLanguages();

        List<String> resultLangs = settingViewModel.learningLanguagesList;
        List<String> correctList = List.of({'ÖGS', 'DGS'});
        expect(resultLangs, containsAll(correctList));
      });

      test('Test 4 - persisted langs in the shared preferences does not influence the result', () async {
        List<Lecture> localLectures = List.of({
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "ÖGS",
              date: '2021-04-04'),
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "DGS",
              date: '2021-04-04'),
        });
        List<Lecture> remoteLectures = List.of({
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "DGS",
              date: '2021-04-04'),
          Lecture(
              id: 1,
              fileName: "",
              fileSize: 5,
              vocableCount: 5,
              pack: "",
              lesson: "",
              lessonSort: "",
              langVocable: "",
              langMedia: "ES",
              date: '2021-04-04'),
        });
        LectaryData lectaryData = LectaryData(lessons: remoteLectures, abstracts: [], codings: []);

        List<String> savedLangs = List.of({
          'FR',
          'RU',
        });
        SharedPreferences.setMockInitialValues({Constants.keySettingLearningLanguageList: savedLangs});

        final mockRepo = MockLectureRepository();
        when(mockRepo.loadLectaryData()).thenAnswer((_) async => Future.value(lectaryData));
        when(mockRepo.loadLecturesLocal()).thenAnswer((_) async => Future.value(localLectures));

        SettingViewModel settingViewModel = SettingViewModel(lectureRepository: mockRepo);
        await settingViewModel.updateLearningLanguages();

        List<String> resultLangs = settingViewModel.learningLanguagesList;
        List<String> correctList = List.of({'ÖGS', 'DGS', 'ES'});
        expect(resultLangs, containsAll(correctList));
      });
    });
  });
}
