import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/models/lectary_overview.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/exceptions/no_internet_exception.dart';
import 'package:lectary/utils/exceptions/server_response_exception.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Endpoint for the communication with the lectary API.
class LectaryApi {
  final http.Client _client;

  static bool isDebug = false;

  LectaryApi(this._client);

  /// Fetches all available data from the lectary API.
  /// Returns a [LectaryData] as [Future].
  /// Throws [NoInternetException] if there is no internet connection
  /// and [ServerResponseException] on any other errors.
  Future<LectaryData> fetchLectaryData() async {
    http.Response response;
    try {
      final endpoint = isDebug
          ? Constants.lectaryApiLectureOverviewDebugEndpoint
          : Constants.lectaryApiLectureOverviewEndpoint;
      response = await _client.get(Uri.https(Constants.lectaryApiUrl, endpoint));
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

  /// Downloads the archive from the passed [Lecture].
  /// Returns a [File] as [Future].
  /// Throws [NoInternetException] if there is no internet connection
  /// and [ServerResponseException] on any other errors or if the lecture could
  /// not be found, with corresponding error messages.
  Future<File> downloadLectureZip(Lecture lecture, String filePath) async {
    http.Response response;
    try {
      final endpoint = isDebug ? Constants.lectaryApiDownloadDebugPath : Constants.lectaryApiDownloadPath;
      response = await _client.get(
          Uri.https(Constants.lectaryApiUrl, endpoint + lecture.fileName));
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      File file = File('$filePath/${lecture.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else if (response.statusCode == 404) {
      throw ServerResponseException("Lecture: ${lecture.lesson} not found!");
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }

  /// Downloads the abstract file from the passed [Abstract].
  /// Returns a [File] as [Future].
  /// Throws [NoInternetException] if there is no internet connection
  /// and [ServerResponseException] on any other errors or if the abstract could
  /// not be found, with corresponding error messages.
  Future<File> downloadAbstractFile(Abstract abstract, String filePath) async {
    http.Response response;
    try {
      final endpoint = isDebug ? Constants.lectaryApiDownloadDebugPath : Constants.lectaryApiDownloadPath;
      response = await _client.get(
          Uri.https(Constants.lectaryApiUrl, endpoint + abstract.fileName));
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      File file = File('$filePath/${abstract.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else if (response.statusCode == 404) {
      throw ServerResponseException("Abstract: ${abstract.pack} not found!");
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }

  /// Downloads the coding file from the passed [Coding].
  /// Returns a [File] as [Future].
  /// Throws [NoInternetException] if there is no internet connection
  /// and [ServerResponseException] on any other errors or if the coding could
  /// not be found, with corresponding error messages.
  Future<File> downloadCodingFile(Coding coding, String filePath) async {
    http.Response response;
    try {
      final endpoint = isDebug ? Constants.lectaryApiDownloadDebugPath : Constants.lectaryApiDownloadPath;
      response = await _client.get(
          Uri.https(Constants.lectaryApiUrl, endpoint + coding.fileName));
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      File file = File('$filePath/${coding.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else if (response.statusCode == 404) {
      throw ServerResponseException("Coding: ${coding.lang} not found!");
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }

  /// Function for reporting errors back to the lectary server.
  /// Params are the [timestamp], in the format 'yyyy-MM-dd-HH_mm', and an [errorMessage].
  /// Returns a [Future] with a [http.Response].
  static Future<http.Response?> reportErrorToServer(String timestamp, String errorMessage) async {
    if (kDebugMode) return null;

    // check correct timestamp format
    try {
      final format = DateFormat('yyyy-MM-dd-HH_mm');
      format.parse(timestamp);
    } catch (e) {
      log("Error reporting failed! Reason: ${e.toString()}");
      return null;
    }

    // enrich error message
    final package = await PackageInfo.fromPlatform();
    errorMessage += "\n(Build: ${package.buildNumber}, Platform: ${Platform.operatingSystem} - ${Platform.operatingSystemVersion})";

    http.Response? response;
    try {
      http.post(
        Uri.https(Constants.lectaryApiUrl, Constants.lectaryApiErrorEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        // pass body params as map, which will be threaten as formData by the http-package
        body: <String, String>{'time': timestamp, 'message': errorMessage},
      );
      return response;
    } catch (e) {
      log("Error reporting failed! Reason: ${e.toString()}");
      return null;
    }
  }
}
