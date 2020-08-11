import 'package:flutter/material.dart';

class SettingViewModel with ChangeNotifier {
  static const bool defaultPlayMediaWithSound = true;
  static const bool defaultShowVideoTimeline = true;
  static const bool defaultShowMediaOverlay = true;
  static const bool defaultUppercase = false;
  static const String defaultAppLanguage = "DE";
  static const String defaultLearningLanguage = "OGS";

  static const List<String> appLanguagesList = ["DE", "EN"];
  static const List<String> learningLanguagesList = ["OGS", "DGS", "EN"];

  bool settingPlayMediaWithSound = defaultPlayMediaWithSound;
  bool settingShowVideoTimeline = defaultShowVideoTimeline;
  bool settingShowMediaOverlay = defaultShowMediaOverlay;
  bool settingUppercase = defaultUppercase;
  String settingAppLanguage = defaultAppLanguage;
  String settingLearningLanguage = defaultLearningLanguage;

  SettingViewModel() {
    _loadLocalSettings();
  }

  void _loadLocalSettings() {
    // TODO Implement
  }

  void toggleSettingPlayMediaWithSound() {
    settingPlayMediaWithSound = settingPlayMediaWithSound ? false : true;
    notifyListeners();
  }

  void toggleSettingShowVideoTimeline() {
    settingShowVideoTimeline = settingShowVideoTimeline ? false : true;
    notifyListeners();
  }

  void toggleSettingShowMediaOverlay() {
    settingShowMediaOverlay = settingShowMediaOverlay ? false : true;
    notifyListeners();
  }

  void toggleSettingUppercase() {
    settingUppercase = settingUppercase ? false : true;
    notifyListeners();
  }

  void setSettingAppLanguage(String lang) {
    settingAppLanguage = lang;
    notifyListeners();
  }

  void setSettingLearningLanguage(String lang) {
    settingLearningLanguage = lang;
    notifyListeners();
  }

  void resetLearningProgress() {
    //TODO Implement
  }

  void resetAllSettings() {
    //TODO Implement
  }
}