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
    String text = asciifiedString;

    // 2020-04-19
    //
    // this one(s) first, otherwise lots of _ from other replaces
    text = text.replaceAll("_UU", "_");
    text = text.replaceAll("__", " ");

    // problembaeren
    text = text.replaceAll("_HK", '"' ); // TAKE CARE OF THIS IN FILENAME
    text = text.replaceAll("_VS", "/" ); // TAKE CARE OF THIS -> PATH DIVIDER

    // german special characters
    text = text.replaceAll("_Ae", "Ä");
    text = text.replaceAll("_Oe", "Ö");
    text = text.replaceAll("_Ue", "Ü");
    text = text.replaceAll("_ae", "ä");
    text = text.replaceAll("_oe", "ö");
    text = text.replaceAll("_ue", "ü");
    text = text.replaceAll("_ss", "ß");
    text = text.replaceAll("_SS", "ß"); // grosses scharfes S

    // german keyboard layout - first row (with <shift>)
    text = text.replaceAll("_GG", "°");
    text = text.replaceAll("_RR", "!" );
    text = text.replaceAll("_PARA", "§" );
    text = text.replaceAll("_DOLLAR", "\$" );
    text = text.replaceAll("_PERCENT", "%" );
    text = text.replaceAll("_AMP", "&" );
    text = text.replaceAll("_KK", "(");
    text = text.replaceAll("_ZZ", ")");
    text = text.replaceAll("_EQUAL", "=");
    text = text.replaceAll("_FF", "?");
    text = text.replaceAll("_GRAC", "`"); // Grave Accent
    text = text.replaceAll("_AKUT", "´"); // Akut

    // german keyboard layout - first row (with <alt gr>)
    text = text.replaceAll("_CFLX", "^"); //Circumflex
    text = text.replaceAll("_CBO", "{"); // curly brackets open
    text = text.replaceAll("_SBO", "["); // square brackets open
    text = text.replaceAll("_SBC", "]"); // square brackets close
    text = text.replaceAll("_CBC", "}"); // curly brackets close
    text = text.replaceAll("_RS", "\\");
    text = text.replaceAll("_ACAC", "`"); // Acute Accent

    // special characters (german layout - second row)
    text = text.replaceAll("_ATSY", "@"); // at symbol
    text = text.replaceAll("_EURO", "€");
    text = text.replaceAll("_STAR", "*" );
    text = text.replaceAll("_PLUS", "+");
    text = text.replaceAll("_TILDE", "~");

    // special characters (german layout - third row)
    text = text.replaceAll("_AP", "'"); // not an APOSTROPHE - single quotation mark
    text = text.replaceAll("_HASH", "//"); // number sign

    // special characters (german layout - fourth row)
    text = text.replaceAll("_LESSER", "<");
    text = text.replaceAll("_GREATER", ">");
    text = text.replaceAll("_VERTBAR", "|"); // vertical bar
    text = text.replaceAll("_SP", ";");
    text = text.replaceAll("_COMMA", ",");
    text = text.replaceAll("_DP", ":");
    text = text.replaceAll("_PP", ".");
    text = text.replaceAll("_-", "-");

    // additional abbreviations
    text = text.replaceAll("_MARKE", " (Marke)");
    text = text.replaceAll("_LADEN", " (Geschäft)");
    text = text.replaceAll("_VAR1", " (Variante 1)");
    text = text.replaceAll("_VAR2", " (Variante 2)");
    text = text.replaceAll("_VAR3", " (Variante 3)");
    text = text.replaceAll("_VAR4", " (Variante 4)");
    text = text.replaceAll("_VAR5", " (Variante 5)");
    text = text.replaceAll("_VAR6", " (Variante 6)");
    text = text.replaceAll("_VAR7", " (Variante 7)");
    text = text.replaceAll("_VAR8", " (Variante 8)");
    text = text.replaceAll("_VAR9", " (Variante 9)");

    return text;
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