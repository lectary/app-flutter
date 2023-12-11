class Constants {
  // general
  static const bool defaultAppFreshInstalled = true;
  static const String databaseName = "lectary.db";

  // device breakpoints for responsive layout
  static const double breakpointTablet = 800;

  // api
  static const lectaryApiUrl = "lectary.net";
  static const _lectaryApiVersionPath = "/l4/";
  static const lectaryApiDownloadPath = _lectaryApiVersionPath;
  static const lectaryApiLectureOverviewEndpoint = "${_lectaryApiVersionPath}info.php";
  static const lectaryApiErrorEndpoint = "${_lectaryApiVersionPath}error.php";

  // carousel
  static const opacityOfCarouselOverLay = 0.5;

  // media
  static const double aspectRatio = 4 / 3;
  static const double slowModeSpeed = 0.3;
  static const int mediaAnimationDurationMilliseconds = 2000;

  // settings
  static const bool defaultPlayMediaWithSound = false;
  static const bool defaultShowVideoTimeline = true;
  static const bool defaultShowMediaOverlay = true;
  static const bool defaultUppercase = false;
  static const String defaultAppLanguage = "de";
  static const List<String> appLanguagesList = ["de", "en"];
  static const String defaultLearningLanguage = "ÖGS";
  static const List<String> defaultLearningLanguagesList = ["ÖGS", "DGS"];

  // keys for SharedPreferences
  static const String keySelection = "selection";
  static const String keySelectionAll = "selection";
  static const String keySelectionPackage = "package";
  static const String keySelectionLecture = "lecture";
  static const String keyItemIndex = "itemIndex";

  static const String keySettingAppFreshInstalled = "settingAppFreshInstalled";
  static const String keySettingPlayMediaWithSound = "settingPlayMediaWithSound";
  static const String keySettingShowVideoTimeline = "settingShowVideoTimeline";
  static const String keySettingShowMediaOverlay = "settingShowMediaOverlay";
  static const String keySettingUppercase = "settingUppercase";
  static const String keySettingAppLanguage = "settingAppLanguage";
  static const String keySettingLearningLanguage = "settingLearningLanguage";
  static const String keySettingLearningLanguageList = "settingLearningLanguageList";

  // semantic labels used for screen readers
  static const String semanticCloseVirtualLecture = "Virtuelle Lektion schließen";
  static const String semanticCloseSearch = "Suchfunktion schließen";
  static const String semanticSearch = "Suchfunktion";
  static const String semanticClearFilter = "Suchfeld leeren";
  static const String semanticSlowMode = "Medium langsam abspielen";
  static const String semanticAutoMode = "Medium automatisch starten";
  static const String semanticReplayMode = "Medium automatisch wiederholen";
  static const String semanticHideVocable = "Vokabel verbergen";
  static const String semanticShowVocable = "Vokabel einblenden";
  static const String semanticRandomVocable = "Zufälliges Medium auswählen";
  static const String semanticActivateLearningProgress = "Lernfortschritt einblenden";
  static const String semanticDeactivateLearningProgress = "Lernfortschritt ausblenden";
  static const String semanticLearningProgress = "Lernfortschritt protokollieren, Status:";
  static const String semanticMediumVideo = "Video Medium";
  static const String semanticMediumImage = "Bild Medium";
  static const String semanticMediumText = "Text Medium";
  static const String semanticOpenMenu = "Menü öffnen";
  static const String semanticOpenAbstract = "Abstract anzeigen";
}
