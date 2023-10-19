import 'dart:developer';

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

    test('test_whenTrue_thenEmpty', () async {
      mockApiAnswerWithDebugFlagValue(true);
      verifyLessonIsPresent(false);
    });
    test('test_whenFalse_thenPresent', () async {
      mockApiAnswerWithDebugFlagValue(false);
      verifyLessonIsPresent(true);
    });
  });

  group('Test debug flag with debug api', () {
    final api = LectaryApi(client, isDebug: true);
    verifyLessonIsPresent(bool isPresent) => verifyLessonIsPresentWrapper(api, isPresent);

    test('test_whenTrue_thenPresent', () async {
      mockApiAnswerWithDebugFlagValue(true);
      verifyLessonIsPresent(true);
    });
    test('test_whenFalse_thenPresent', () async {
      mockApiAnswerWithDebugFlagValue(false);
      verifyLessonIsPresent(true);
    });
  });
}
