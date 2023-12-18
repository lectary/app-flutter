import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lectary/data/api/lectary_api.dart';
import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/exceptions/server_response_exception.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'lectary_api_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final client = MockClient();
  final api = LectaryApi(client);

  verifyOverviewEndpointIsDebug(bool isDebug) async {
    when(client.get(any)).thenAnswer((_) async => http.Response("""
        {
          "lesson": [],
          "abstract": [],
          "asciify": []
        }
        """, 200));
    await api.fetchLectaryData();
    final endpoint = isDebug
        ? Constants.lectaryApiLectureOverviewDebugEndpoint
        : Constants.lectaryApiLectureOverviewEndpoint;
    final actual = verify(client.get(captureAny)).captured.toString();
    expect(actual, contains(endpoint));
  }


  group('Test overview api debug modus', () {
    test('test_whenDebugOverride_thenDebugEndpoint', () async {
      LectaryApi.isDebug = true;
      verifyOverviewEndpointIsDebug(true);
    });
    test('test_whenNoDebugOverride_thenNoDebugEndpoint', () async {
      LectaryApi.isDebug = false;
      verifyOverviewEndpointIsDebug(false);
    });
  });

  verifyDownloadEndpointIsDebug(bool isDebug, Function apiCall) async {
    when(client.get(any)).thenAnswer((_) async => http.Response("", 404)); // 404 bypasses file logic
    apiCall.call();
    final endpoint = isDebug
        ? Constants.lectaryApiDownloadDebugPath
        : Constants.lectaryApiDownloadPath;
    final actual = verify(client.get(captureAny)).captured.toString();
    expect(actual, contains(endpoint));
  }

  group('Test download api lectures debug modus', () {
    apiCallLecture() {
      var lecture = Lecture(fileName: "fileName", fileSize: 0, vocableCount: 0, pack: "pack", lesson: "lesson", lessonSort: "lessonSort", langMedia: "langMedia", langVocable: "langVocable", date: "date");
      expect(() => api.downloadLectureZip(lecture, "testPath"), throwsA(isA<ServerResponseException>()));
    }
    test('test_whenDebugOverride_thenDebugEndpoint', () async {
      LectaryApi.isDebug = true;
      verifyDownloadEndpointIsDebug(true, apiCallLecture);
    });
    test('test_whenNoDebugOverride_thenNoDebugEndpoint', () async {
      LectaryApi.isDebug = false;
      verifyDownloadEndpointIsDebug(false, apiCallLecture);
    });
  });

  group('Test download api abstracts debug modus', () {
    apiCallAbstract() {
      var abstract = Abstract(fileName: "fileName", pack: "pack", text: "text", date: "date");
      expect(() => api.downloadAbstractFile(abstract, "testPath"), throwsA(isA<ServerResponseException>()));
    }
    test('test_whenDebugOverride_thenDebugEndpoint', () async {
      LectaryApi.isDebug = true;
      verifyDownloadEndpointIsDebug(true, apiCallAbstract);
    });
    test('test_whenNoDebugOverride_thenNoDebugEndpoint', () async {
      LectaryApi.isDebug = false;
      verifyDownloadEndpointIsDebug(false, apiCallAbstract);
    });
  });

  group('Test download api codings debug modus', () {
    apiCallCoding() {
      var coding = Coding(fileName: "fileName", lang: "lang", date: "date");
      expect(() => api.downloadCodingFile(coding, "testPath"), throwsA(isA<ServerResponseException>()));
    }
    test('test_whenDebugOverride_thenDebugEndpoint', () async {
      LectaryApi.isDebug = true;
      verifyDownloadEndpointIsDebug(true, apiCallCoding);
    });
    test('test_whenNoDebugOverride_thenNoDebugEndpoint', () async {
      LectaryApi.isDebug = false;
      verifyDownloadEndpointIsDebug(false, apiCallCoding);
    });
  });
}
