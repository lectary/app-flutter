import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
          ? Constants.apiPathLectureOverviewDebug
          : Constants.apiPathLectureOverview;
      response = await _client.get(Uri.https(Constants.lectaryHost, endpoint));
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
      final endpoint = isDebug ? Constants.apiPathDownloadDebug : Constants.apiPathDownload;
      response = await _client.get(
          Uri.https(Constants.lectaryHost, endpoint + lecture.fileName));
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
      final endpoint = isDebug ? Constants.apiPathDownloadDebug : Constants.apiPathDownload;
      response = await _client.get(
          Uri.https(Constants.lectaryHost, endpoint + abstract.fileName));
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
      final endpoint = isDebug ? Constants.apiPathDownloadDebug : Constants.apiPathDownload;
      response = await _client.get(
          Uri.https(Constants.lectaryHost, endpoint + coding.fileName));
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

    // enrich error message
    final package = await PackageInfo.fromPlatform();
    errorMessage += "\nRunning on Build: ${package.buildNumber}, Platform: ${Platform.operatingSystem}";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      errorMessage +=  " - ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}), Model: ${androidInfo.manufacturer} ${androidInfo.model}";
    }
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      errorMessage += " - ${iosInfo.systemVersion}, Model: ${iosInfo.model}";
    }

    http.Response? response;
    try {
      http.post(
        Uri.https(Constants.lectaryHost, Constants.apiPathErrorReport),
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
