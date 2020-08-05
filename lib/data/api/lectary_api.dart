import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/models/lectary_overview.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/exceptions/no_internet_exception.dart';
import 'package:lectary/utils/exceptions/server_response_exception.dart';
import 'package:path_provider/path_provider.dart';

class LectaryApi {

  Future<LectaryData> fetchLectaryData() async {
    http.Response response;
    try {
      response = await http.get(Constants.lectaryApiUrl + Constants.lectaryApiLectureOverviewEndpoint);
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      return LectaryData.fromJson(json.decode(response.body));
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

  Future<File> downloadAbstractFile(Abstract abstract) async {
    String dir = (await getTemporaryDirectory()).path;

    http.Response response;
    try {
      response = await http.get(Constants.lectaryApiUrl + abstract.fileName);
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      File file = File('$dir/${abstract.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }

}