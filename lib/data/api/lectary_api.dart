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
import 'package:path_provider/path_provider.dart';

/// Endpoint for the communication with the lectary API.
class LectaryApi {
  final http.Client _client;
  final bool isDebug;

  LectaryApi(this._client, {this.isDebug = false});

  /// Fetches all available data from the lectary API.
  /// Returns a [LectaryData] as [Future].
  /// Throws [NoInternetException] if there is no internet connection
  /// and [ServerResponseException] on any other errors.
  Future<LectaryData> fetchLectaryData() async {
    http.Response response;
    try {
      response = await _client
          .get(Uri.https(Constants.lectaryApiUrl, Constants.lectaryApiLectureOverviewEndpoint));
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      return LectaryData.fromJson(json.decode(response.body), isDebug);
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
  Future<File> downloadLectureZip(Lecture lecture) async {
    String dir = (await getTemporaryDirectory()).path;

    http.Response response;
    try {
      response = await _client.get(
          Uri.https(Constants.lectaryApiUrl, Constants.lectaryApiDownloadPath + lecture.fileName));
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      File file = File('$dir/${lecture.fileName}');
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
  Future<File> downloadAbstractFile(Abstract abstract) async {
    String dir = (await getTemporaryDirectory()).path;

    http.Response response;
    try {
      response = await _client.get(
          Uri.https(Constants.lectaryApiUrl, Constants.lectaryApiDownloadPath + abstract.fileName));
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      File file = File('$dir/${abstract.fileName}');
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
  Future<File> downloadCodingFile(Coding coding) async {
    String dir = (await getTemporaryDirectory()).path;

    http.Response response;
    try {
      response = await _client.get(
          Uri.https(Constants.lectaryApiUrl, Constants.lectaryApiDownloadPath + coding.fileName));
    } on SocketException {
      throw NoInternetException("No internet! Check your connection!");
    }

    if (response.statusCode == 200) {
      File file = File('$dir/${coding.fileName}');
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
