import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:archive/archive.dart';
import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/utils/exceptions/archive_structure_exception.dart';
import 'package:lectary/utils/exceptions/media_type_exception.dart';
import 'package:collection/collection.dart';
import 'exceptions/lecture_exception.dart';

/// Helper class with multiple static functions for sorting, validation or extracting
/// Metadata.
class Utils {

  /// Custom compare function which uses [replaceForSort] to replace special
  /// german letters with equivalent characters used for sorting.
  static int customCompareTo(String a, String b) {
    a = replaceForSort(a);
    b = replaceForSort(b);
    return a.compareTo(b);
  }

  /// Replaces special german characters with placeholder used for sorting.
  static String replaceForSort(String text) {
    text = text.replaceAll("ü", 'uzzzz');
    text = text.replaceAll("Ü", 'uzzzz');
    text = text.replaceAll("Ä", 'azzzz');
    text = text.replaceAll("ä", 'azzzz');
    text = text.replaceAll("ö", 'ozzzz');
    text = text.replaceAll("Ö", 'ozzzz');
    text = text.replaceAll("St.", 'Sanktzzzz');
    text = text.toLowerCase();
    return text;
  }

  /// Groups a lecture list by the lecture pack
  /// Returns a [List] of [LecturePackage]
  static List<LecturePackage> groupLecturesByPack(List<Lecture> lectureList) {
    final lecturesByPack = groupBy(lectureList, (lecture) => (lecture as Lecture).pack);
    List<LecturePackage> packList = List();
    lecturesByPack.forEach((key, value) => packList.add(LecturePackage(key, value)));
    return packList;
  }

  /// Validates whether the archive structure is valid in regards of the following conditions:
  /// 1) nested directories are not allowed
  /// 2) the name of the inner directory must match the outer archive name
  /// 3) only file-types of type MediaType are allowed
  /// 4) media files must have a filename (i.e. representing the vocable)
  /// returns [True] if validation was successful
  /// throws [ArchiveStructureException] on error
  static bool validateArchive(File zipFile, Archive archive) {
    String dirName = Utils.extractFileName(zipFile.path);

    // check conditions and directory structure for and by every file in archive,
    // since it seems that there is no consistent way
    // of receiving information about the directory structure
    for (ArchiveFile file in archive) {
      // replacing windows path divider to unix' one
      String filename = file.name.replaceAll('\\', '/');
      if (!file.isFile) continue;
      // check if there are media files without a name i.e. missing vocable
      if (Utils.extractFileName(filename).isEmpty)
        throw new ArchiveStructureException("File without filename found");
      // check if there are nested directories by splitting filename by path divider '/'
      if (filename.split('/').length > 2)
        throw new ArchiveStructureException(
            "Wrong archive structure: $filename");
      // check if inner directory name matches zip-filename
      if (dirName != Utils.extractDirName(filename))
        throw new ArchiveStructureException(
            "Inner directory name should be equal the archive name!\nZipArchive: $dirName <-> directory: $filename");
      // check if archive consists only of valid file types
      try {
        String extension = Utils.extractFileExtension(filename);
        MediaType.fromString(extension);
      } on MediaTypeException catch (e) {
        throw new ArchiveStructureException(e.toString());
      }
    }

    return true;
  }

  /// extracts the filename out of an file path
  static String extractFileName(String filename) {
    // replace all windows backslash with normal slash
    filename = filename.replaceAll('\\', '/');
    if (filename.isEmpty) return "";
    return filename.contains('.')
        ? filename.substring(
            filename.lastIndexOf('/') + 1, filename.lastIndexOf('.'))
        : filename.substring(filename.lastIndexOf('/') + 1);
  }

  /// extracts the most inner directory name out of an file path
  static String extractDirName(String filename) {
    // replace all windows backslash with normal slash
    filename = filename.replaceAll('\\', '/');
    if (!filename.contains('/')) return "";
    return filename.split('/')[filename.split('/').length - 2];
  }

  /// extracts the file extension out of an file path
  static String extractFileExtension(String filename) {
    if (!filename.contains('.')) return "";
    int indexDot = filename.lastIndexOf('.');
    int indexLastPath = filename.lastIndexOf('/');
    if (indexLastPath > indexDot) return "";
    return filename.substring(filename.lastIndexOf('.') + 1);
  }

  /// extracts the date meta info
  /// returns an empty string if filename is invalid or date meta info is missing
  static String extractDateMetaInfoFromFilename(String filename) {
    if (!filename.contains('.') || !filename.contains('DATE')) return "";
    List<String> filenameSplit = filename.split('.');
    if (filenameSplit.length != 2) return "";
    List<String> metaInfo = filenameSplit[0].split('---');
    if (metaInfo.length == 0) return "";
    List<String> dateSplit = metaInfo.firstWhere((element) => element.contains("DATE")).split('--');
    if (dateSplit.length != 2) return "";
    return dateSplit[1];
  }

  /// Extracts the meta information out of an [Lecture]] filename.
  /// Returns a [Map] with the meta data.
  /// Throws [LectureException] if mandatory meta data is missing
  /// Used keys {optional}: PACK, LESSON, LESSON-SORT, LANG-MEDIA, LANG-VOCABLE, {AUDIO}, {DATE}, {SORT}
  static Map<String, dynamic> extractMetaDataFromLectureFile(String fileName) {
    Map<String, dynamic> result = Map();

    if (!fileName.contains(".zip"))
      throw new LectureException("Missing .zip ending in filename: $fileName");
    String fileWithoutType = fileName.split(".zip")[0];
    if (!fileWithoutType.contains("PACK") || !fileWithoutType.contains("LESSON") || !fileWithoutType.contains("LANG")) {
      throw new LectureException("File has not mandatory meta information!\n"
          "Missing:"
          "${!fileWithoutType.contains("PACK") ? " PACK " : ""}"
          "${!fileWithoutType.contains("LESSON") ? " LESSON " : ""}"
          "${!fileWithoutType.contains("LANG") ? " LANG " : ""}"
          "\nFile: $fileWithoutType"
      );
    }

    List<String> metaData = fileWithoutType.split("---");
    for (String metaDatum in metaData) {
      List<String> split = metaDatum.split("--");
      if (split.length != 2) {
        throw new LectureException("Malformed meta info: $metaDatum of lecture $fileName");
      }
      String metaInfoType = split[0];
      String metaInfoValue = split[1];

      switch(metaInfoType) {
        case "PACK":
          result.putIfAbsent("PACK", () => deAsciify(metaInfoValue));
          break;
        case "LESSON":
          String lesson = deAsciify(metaInfoValue);
          result.putIfAbsent("LESSON", () => lesson);
          result.putIfAbsent("LESSON-SORT", () => replaceForSort(lesson));
          break;
        case "LANG":
          List<String> langs = metaInfoValue.split("-");
          if (langs.length != 2) {
            throw new LectureException("Malformed LANG meta info: $metaInfoValue");
          }
          String langMedia = deAsciify(langs[0]);
          if (langMedia == "OGS") langMedia = "ÖGS"; // convert legacy 'OGS'-lectures to 'ÖGS'
          result.putIfAbsent("LANG-MEDIA", () => langMedia); // deAsciifying due to possible special german characters like in 'ÖGS'
          result.putIfAbsent("LANG-VOCABLE", () => (langs[1])); // no deAsciifying, because the langs are of ISO 639-1, which does not contain any special characters
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

  /// Extracts the vocable itself and possible meta data out of an [Vocable] filename.
  /// Returns a [Map] with the vocable and meta data.
  /// Used keys {optional}: VOCABLES, {AUDIO}, {SORT}
  static Map<String, dynamic> extractMetaDataFromVocableFile(String fileName) {
    Map<String, dynamic> result = Map();

    // check if there are metaData
    if (fileName.contains("---")) {
      List<String> metaData = fileName.split("---");
      // the first one is always the vocable itself
      result.putIfAbsent("VOCABLE", () => metaData.removeAt(0));
      for (String metaDatum in metaData) {
        // extracting metaData
        List<String> split = metaDatum.split("--");
        if (split.length != 2) {
          log("Malformed meta data: $metaDatum of vocable $fileName");
          // ignore meta info for this vocable in case of malformation
          continue;
        }
        String metaDatumType = split[0];
        String metaDatumValue = split[1];

        switch (metaDatumType) {
          case "AUDIO":
            result.putIfAbsent("AUDIO", () => metaDatumValue);
            break;
          case "SORT":
            result.putIfAbsent("SORT", () => metaDatumValue);
            break;
        }
      }
    } else {
      result.putIfAbsent("VOCABLE", () => fileName);
    }

    return result;
  }


  /// Returns a string where all asciified parts are replaced with the corresponding characters
  static String deAsciify(String asciifiedString, {List<CodingEntry> codingEntries}) {
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

    if (codingEntries != null) {
      codingEntries.forEach((entry) {
        text = text.replaceAll(entry.ascii, entry.char);
      });
    }

    return text;
  }
  
  /// Returns the current date in the ISO-8601 format 'yyyy-MM-dd'
  static String currentDate() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// Returns a string filled with leading zeros up to a length of 5
  static String fillWithLeadingZeros(String string) {
    final int maxLength = 5;
    return string.padLeft(maxLength, '0');
  }

  /// Returns the index of one random selected vocable of the passed list of [Vocable]
  /// If [vocableProgressEnabled] is [True], then the [Vocable.vocableProgress] will
  /// be considered when choosing a vocable, the better the progress, the rarer a
  /// vocable will be chosen
  static int chooseRandomVocable(bool vocableProgressEnabled, List<Vocable> vocables) {
    math.Random random = new math.Random();
    int rndPage;
    if (vocableProgressEnabled) {
      List<Vocable> distributedVocableList = List();
      vocables.forEach((voc) {
        switch(voc.vocableProgress) {
          case 0:
            distributedVocableList.add(voc);
            distributedVocableList.add(voc);
            distributedVocableList.add(voc);
            break;
          case 1:
            distributedVocableList.add(voc);
            distributedVocableList.add(voc);
            break;
          case 2:
            distributedVocableList.add(voc);
            break;
        }
      });
      int rndIndex = random.nextInt(distributedVocableList.length);
      Vocable vocable = distributedVocableList[rndIndex];
      rndPage = vocables.indexOf(vocable);
    } else {
      rndPage = random.nextInt(vocables.length);
    }
    return rndPage;
  }
}