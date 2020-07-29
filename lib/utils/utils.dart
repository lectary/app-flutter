import 'dart:developer';

class Utils {

  static Map<String, dynamic> extractMetaInformation(String fileName) {
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

      switch(metaInfoType) {
        case "PACK":
          result.putIfAbsent("PACK", () => _deAsciify(metaInfoValue));
          break;
        case "LESSON":
          result.putIfAbsent("LESSON", () => _deAsciify(metaInfoValue));
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


  static String _deAsciify(String asciifiedString) {
    String result = asciifiedString;

    // TODO add all cases
    result = result.replaceAll("_-", "-");
    result = result.replaceAll("__", " ");
    result = result.replaceAll("_VS", "/");
    result = result.replaceAll("_ae", "ä");

    return result;
  }
  
  /// Returns current date in the format 'yyyy-MM-dd'
  static String currentDate() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  static String fillWithLeadingZeros(String string) {
    final int maxLength = 5;
    return string.padLeft(maxLength, '0');
  }
}