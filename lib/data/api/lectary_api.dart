import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/exceptions/no_internet_exception.dart';
import 'package:lectary/utils/exceptions/server_response_exception.dart';
import 'package:path_provider/path_provider.dart';

class LectaryApi {
  Future<List<Lecture>> fetchLectures() async {
    http.Response response;
    try {
      response = await http.get(Constants.lectaryApiUrl + Constants.lectaryApiLectureOverviewEndpoint);
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      List<Lecture> resultList;

      Map<String, dynamic> rawResponse = json.decode(response.body);
      List<dynamic> lessons = rawResponse['lesson'];
      log("Lessons: " + rawResponse.toString());

      resultList = lessons.map((element) => Lecture.fromJson(element)).where((element) => element != null).toList();
      return resultList;
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }

  Future<File> downloadLectureZip(Lecture lecture) async {
    String dir = (await getTemporaryDirectory()).path;

    http.Response response;
    try {
      response = await http.get(Constants.lectaryApiUrl + lecture.fileName);
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      File file = File('$dir/${lecture.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }
}