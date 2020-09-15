import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lectary_overview.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

class MockLectureRepository extends Mock implements LectureRepository {}

void main() async {
  group('Tests for SettingViewModel', () {

    group('Group 1 - Testing behaviour of updating of learning languages', () {

      test('Test 1 - a local language, that is not in the remote list, appears in the result list', () async {
        List<Lecture> localLectures = List.of({
          Lecture(langMedia: 'de'),
          Lecture(langMedia: 'en'),
        });
        List<Lecture> remoteLectures = List.of({
          Lecture(langMedia: 'de'),
          Lecture(langMedia: 'es'),
        });
        LectaryData lectaryData = LectaryData(lessons: remoteLectures);

        SharedPreferences.setMockInitialValues({});

        final mockRepo = MockLectureRepository();
        when(mockRepo.loadLectaryData()).thenAnswer((_) async => Future.value(lectaryData));
        when(mockRepo.loadLecturesLocal()).thenAnswer((_) async => Future.value(localLectures));

        SettingViewModel settingViewModel = SettingViewModel(lectureRepository: mockRepo);
        await settingViewModel.updateLearningLanguages();

        List<String> resultLangs = settingViewModel.learningLanguagesList;
        List<String> correctList = List.of({'ALLE', 'de', 'en', 'es'});
        expect(resultLangs, containsAll(correctList));
      });

      test('Test 2 - with empty local list, only the remote list appears in the result list', () async {
        List<Lecture> localLectures = List.of({
        });
        List<Lecture> remoteLectures = List.of({
          Lecture(langMedia: 'de'),
          Lecture(langMedia: 'es'),
        });
        LectaryData lectaryData = LectaryData(lessons: remoteLectures);

        SharedPreferences.setMockInitialValues({});

        final mockRepo = MockLectureRepository();
        when(mockRepo.loadLectaryData()).thenAnswer((_) async => Future.value(lectaryData));
        when(mockRepo.loadLecturesLocal()).thenAnswer((_) async => Future.value(localLectures));

        SettingViewModel settingViewModel = SettingViewModel(lectureRepository: mockRepo);
        await settingViewModel.updateLearningLanguages();

        List<String> resultLangs = settingViewModel.learningLanguagesList;
        List<String> correctList = List.of({'ALLE', 'de', 'es'});
        expect(resultLangs, containsAll(correctList));
      });

      test('Test 3 - with empty remote list, only the local list appears in the result list', () async {
        List<Lecture> localLectures = List.of({
          Lecture(langMedia: 'de'),
          Lecture(langMedia: 'en'),
        });
        List<Lecture> remoteLectures = List.of({
        });
        LectaryData lectaryData = LectaryData(lessons: remoteLectures);

        SharedPreferences.setMockInitialValues({});

        final mockRepo = MockLectureRepository();
        when(mockRepo.loadLectaryData()).thenAnswer((_) async => Future.value(lectaryData));
        when(mockRepo.loadLecturesLocal()).thenAnswer((_) async => Future.value(localLectures));

        SettingViewModel settingViewModel = SettingViewModel(lectureRepository: mockRepo);
        await settingViewModel.updateLearningLanguages();

        List<String> resultLangs = settingViewModel.learningLanguagesList;
        List<String> correctList = List.of({'ALLE', 'de', 'en'});
        expect(resultLangs, containsAll(correctList));
      });

      test('Test 4 - persisted langs in the shared preferences does not influence the result', () async {
        List<Lecture> localLectures = List.of({
          Lecture(langMedia: 'de'),
          Lecture(langMedia: 'en'),
        });
        List<Lecture> remoteLectures = List.of({
          Lecture(langMedia: 'en'),
          Lecture(langMedia: 'es'),
        });
        LectaryData lectaryData = LectaryData(lessons: remoteLectures);

        List<String> savedLangs = List.of({
          'fr',
          'ru',
        });
        SharedPreferences.setMockInitialValues({Constants.keySettingLearningLanguageList: savedLangs});

        final mockRepo = MockLectureRepository();
        when(mockRepo.loadLectaryData()).thenAnswer((_) async => Future.value(lectaryData));
        when(mockRepo.loadLecturesLocal()).thenAnswer((_) async => Future.value(localLectures));

        SettingViewModel settingViewModel = SettingViewModel(lectureRepository: mockRepo);
        await settingViewModel.updateLearningLanguages();

        List<String> resultLangs = settingViewModel.learningLanguagesList;
        List<String> correctList = List.of({'ALLE', 'de', 'en', 'es'});
        expect(resultLangs, containsAll(correctList));
      });
    });
  });
}