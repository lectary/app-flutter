import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:lectary/models/lecture.dart';

class LectaryApi {
  String lecturesApiUrl = "https://lectary.net/l4/info.php";

  Future<List<Lecture>> fetchLectures() async {
    final response = await http.get(lecturesApiUrl);

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
      throw Exception("Failed to load lectures");
    }
  }

}