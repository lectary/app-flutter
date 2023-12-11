import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lectary/data/api/lectary_api.dart';
import 'package:lectary/utils/constants.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'lectary_api_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final client = MockClient();

  const testLessonName =
      "PACK--Alpen__Adria__Universit_aet---LESSON--AAU__Lektion__6---LANG--OGS-DE---SORT--106---DATE--2019-04-29";

  mockApiAnswerWithDebugFlagValue(bool debug) {
    when(client
            .get(Uri.https(Constants.lectaryApiUrl, Constants.lectaryApiLectureOverviewEndpoint)))
        .thenAnswer(
      (_) async {
        var response = http.Response("""
        {
          "lesson": [{
            "fileName": "$testLessonName${debug ? '---DEBUG' : ''}.zip",
            "fileSize": 5,
            "vocableCount": 42
            }],
          "abstract": [],
          "asciify": []
        }
        """, 200);
        print(response.body);
        return response;
      },
    );
  }

  verifyLessonIsPresentWrapper(LectaryApi api, bool isPresent) async {
    final result = await api.fetchLectaryData();
    expect(result.lessons.isNotEmpty, isPresent ? isTrue : isFalse);
  }

  group('Test debug flag with prod api', () {
    final api = LectaryApi(client);
    verifyLessonIsPresent(bool isPresent) => verifyLessonIsPresentWrapper(api, isPresent);

    test('test_whenFlagMissing_thenLecturePresent', () async {
      LectaryApi.isDebugOverride = false;
      mockApiAnswerWithDebugFlagValue(false);
      verifyLessonIsPresent(true);
    });
    test('test_whenFlagPresent_thenLectureEmpty', () async {
      LectaryApi.isDebugOverride = false;
      mockApiAnswerWithDebugFlagValue(true);
      verifyLessonIsPresent(false);
    });
  });

  group('Test debug flag with prod api and debug override', () {
    final api = LectaryApi(client);
    verifyLessonIsPresent(bool isPresent) => verifyLessonIsPresentWrapper(api, isPresent);

    test('test_whenFlagMissing_thenLectureEmpty', () async {
      LectaryApi.isDebugOverride = true;
      mockApiAnswerWithDebugFlagValue(false);
      verifyLessonIsPresent(true);
    });
    test('test_whenFlagPresent_thenLectureEmpty', () async {
      LectaryApi.isDebugOverride = true;
      mockApiAnswerWithDebugFlagValue(true);
      verifyLessonIsPresent(true);
    });
  });

  group('Test debug flag with debug api', () {
    final api = LectaryApi(client, isDebug: true);
    verifyLessonIsPresent(bool isPresent) => verifyLessonIsPresentWrapper(api, isPresent);

    test('test_whenFlagMissing_thenLectureEmpty', () async {
      LectaryApi.isDebugOverride = false;
      mockApiAnswerWithDebugFlagValue(false);
      verifyLessonIsPresent(true);
    });
    test('test_whenFlagPresent_thenLectureEmpty', () async {
      LectaryApi.isDebugOverride = false;
      mockApiAnswerWithDebugFlagValue(true);
      verifyLessonIsPresent(true);
    });
  });

  group('Test debug flag with debug api and debug override', () {
    final api = LectaryApi(client, isDebug: true);
    verifyLessonIsPresent(bool isPresent) => verifyLessonIsPresentWrapper(api, isPresent);

    test('test_whenFlagMissing_thenLectureEmpty', () async {
      LectaryApi.isDebugOverride = true;
      mockApiAnswerWithDebugFlagValue(false);
      verifyLessonIsPresent(true);
    });
    test('test_whenFlagPresent_thenLectureEmpty', () async {
      LectaryApi.isDebugOverride = true;
      mockApiAnswerWithDebugFlagValue(true);
      verifyLessonIsPresent(true);
    });
  });
}
