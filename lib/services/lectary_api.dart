import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lectary/data/entities/lecture.dart';
import 'package:path_provider/path_provider.dart';

class LectaryApi {
  String lectaryApiUrl = "https://lectary.net/l4/";

  Future<List<Lecture>> fetchLectures() async {
    try {
      final response = await http.get(lectaryApiUrl + "info.php");

      if (response.statusCode == 200) {
        List<Lecture> resultList;

        Map<String, dynamic> rawResponse = json.decode(response.body);
        List<dynamic> lessons = rawResponse['lesson'];
        log("Lessons: " + rawResponse.toString());

        try {
          resultList = lessons.map((element) => Lecture.fromJson(element)).toList();
        }catch(e) {
          log("Mapping failed:" + e.toString());
        }

        return resultList;
      } else {
        throw Exception(response.statusCode.toString() + " - Server refused fetching lectures!");
      }
    } catch(e) {
      log(e.toString());
      throw Exception("Network error!");
    }
  }

  Future<File> downloadLectureZip(Lecture lecture) async {
    log("downloading " + lecture.lesson);

    String dir = (await getTemporaryDirectory()).path;

    try {
      final response = await http.get(lectaryApiUrl + lecture.fileName);
      if (response.statusCode != 200) {
        log("Failed to download lecture with status code ${response.statusCode}");
        throw Exception(response.statusCode.toString() + " - Server refused fetching lectures!");
      }
      File file = File('$dir/${lecture.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch(e) {
      log("Failed to download lecture with exception: " + e.toString());
      throw Exception("Network error!\n" + e.toString());
    }
  }
}