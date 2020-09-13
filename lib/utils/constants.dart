class Constants {
  // api
  static const lectaryApiUrl = "https://lectary.net/l4/";
  static const lectaryApiLectureOverviewEndpoint = "info.php";

  // carousel
  static const opacityOfCarouselOverLay = 0.5;

  // media
  static const double aspectRatio = 4 / 3;
  static const double slowModeSpeed = 0.3;
  static const int mediaAnimationDurationMilliseconds = 2000;

  // settings
  static const bool defaultPlayMediaWithSound = true;
  static const bool defaultShowVideoTimeline = true;
  static const bool defaultShowMediaOverlay = true;
  static const bool defaultUppercase = false;
  static const String defaultAppLanguage = "de";
  static const String defaultLearningLanguage = "OGS";
  static const List<String> appLanguagesList = ["de", "en"];
  static const List<String> defaultLearningLanguagesList = ["OGS", "DGS", "EN"];

  // keys for SharedPreferences
  static const String keySelection = "selection";
  static const String keySelectionAll = "selection";
  static const String keySelectionPackage = "package";
  static const String keySelectionLecture = "lecture";
  static const String keyItemIndex = "itemIndex";

  static const String keySettingPlayMediaWithSound = "settingPlayMediaWithSound";
  static const String keySettingShowVideoTimeline = "settingShowVideoTimeline";
  static const String keySettingShowMediaOverlay = "settingShowMediaOverlay";
  static const String keySettingUppercase = "settingUppercase";
  static const String keySettingAppLanguage = "settingAppLanguage";
  static const String keySettingLearningLanguage = "settingLearningLanguage";
  static const String keySettingLearningLanguageList = "settingLearningLanguageList";
}