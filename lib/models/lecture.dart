import 'dart:developer';

enum LectureStatus { notPersisted, downloading, persisted, removed, updateAvailable }

/// Model class representing a lecture pack
class Lecture {
  int id;

  /// Used for showing corresponding info icons in the lecture list
  LectureStatus lectureStatus = LectureStatus.notPersisted;

  /// Lecture pack properties (.zip)
  final String fileName;
  final int fileSize;
  final int vocableCount;

  /// Possible meta information
  String pack; // mandatory
  String lesson; // mandatory
  String lang; // mandatory
  String audio;
  String date;
  int sort;
  
  Lecture({this.fileName, this.fileSize, this.vocableCount,
      this.pack, this.lesson, this.lang, this.audio, this.date, this.sort});

  /// Deserialization from json
  factory Lecture.fromJson(Map<String, dynamic> json) {
    String fileName = json['fileName'];
    Map<String, dynamic> metaInfo;
    try {
      metaInfo = _extractMetaInformation(fileName);

    } catch(e) {
      log("Extracting:" + e.toString());
    }
    return Lecture(
      fileName: fileName,
      fileSize: json['fileSize'],
      vocableCount: json['vocableCount'],
      pack: metaInfo.remove("PACK"),
      lesson: metaInfo.remove("LESSON"),
      lang: metaInfo.remove("LANG"),
      audio: metaInfo.containsKey("AUDIO") ? metaInfo.remove("AUDIO") : null,
      date: metaInfo.containsKey("DATE") ? metaInfo.remove("DATE") : null,
      sort: metaInfo.containsKey("SORT") ? int.parse(metaInfo.remove("SORT")) : null,
    );
  }

  static Map<String, dynamic> _extractMetaInformation(String fileName) {
    Map<String, dynamic> result = Map();

    String fileWithoutType = fileName.split(".zip")[0];
    if (!fileWithoutType.contains("PACK") || !fileWithoutType.contains("LESSON") || !fileWithoutType.contains("LANG")) {
      // throw new Exception("File has not mandatory meta information!") //FIXME ignore temp due to miss-formatted test cases
      // TODO add mechanic to send error message to server for informing about wrong packages?
      log("File has not mandatory meta information! File: " + fileWithoutType);
    }

    List<String> metaInfos = fileWithoutType.split("---");
    for (String metaInfo in metaInfos) {
      String metaInfoType = metaInfo.split("--")[0];
      String metaInfoValue = metaInfo.split("--")[1];

      // TODO de-asciify

      switch(metaInfoType) {
        case "PACK":
          result.putIfAbsent("PACK", () => metaInfoValue);
          break;
        case "LESSON":
          result.putIfAbsent("LESSON", () => metaInfoValue);
          break;
        case "LANG":
          result.putIfAbsent("LANG", () => metaInfoValue);
          break;
        case "AUDIO":
          result.putIfAbsent("AUDIO", () => metaInfoValue);
          break;
        case "DATE":
          result.putIfAbsent("DATE", () => metaInfoValue);
          break;
        case "SORT":
          result.putIfAbsent("SORT", () => metaInfoValue);
          break;
      }
    }
    return result;
  }

}