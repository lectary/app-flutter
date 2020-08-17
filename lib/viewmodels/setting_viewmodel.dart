import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingViewModel with ChangeNotifier {
  static const bool defaultPlayMediaWithSound = true;
  static const bool defaultShowVideoTimeline = true;
  static const bool defaultShowMediaOverlay = true;
  static const bool defaultUppercase = false;
  static const String defaultAppLanguage = "DE";
  static const String defaultLearningLanguage = "ALLE"; //TODO for testing purposes

  static const List<String> appLanguagesList = ["DE", "EN"];
  static const List<String> learningLanguagesList = ["ALLE", "OGS", "DGS", "EN"];

  static const String _keySettingPlayMediaWithSound = "settingPlayMediaWithSound";
  static const String _keySettingShowVideoTimeline = "settingShowVideoTimeline";
  static const String _keySettingShowMediaOverlay = "settingShowMediaOverlay";
  static const String _keySettingUppercase = "settingUppercase";
  static const String _keySettingAppLanguage = "settingAppLanguage";
  static const String _keySettingLearningLanguage = "settingLearningLanguage";

  bool settingPlayMediaWithSound = defaultPlayMediaWithSound;
  bool settingShowVideoTimeline = defaultShowVideoTimeline;
  bool settingShowMediaOverlay = defaultShowMediaOverlay;
  bool settingUppercase = defaultUppercase;
  String settingAppLanguage = defaultAppLanguage;
  String settingLearningLanguage = defaultLearningLanguage;

  final LectureRepository _lectureRepository;

  SettingViewModel({@required lectureRepository})
      :_lectureRepository = lectureRepository {
    _loadLocalSettings();
  }

  Future<void> _loadLocalSettings() async {
    log("loading local app settings");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    settingPlayMediaWithSound = prefs.getBool(_keySettingPlayMediaWithSound) ?? defaultPlayMediaWithSound;
    settingShowVideoTimeline = prefs.getBool(_keySettingShowVideoTimeline) ?? defaultShowVideoTimeline;
    settingShowMediaOverlay = prefs.getBool(_keySettingShowMediaOverlay) ?? defaultShowMediaOverlay;
    settingUppercase = prefs.getBool(_keySettingUppercase) ?? defaultUppercase;
    settingAppLanguage = prefs.getString(_keySettingAppLanguage) ?? defaultAppLanguage;
    settingLearningLanguage = prefs.getString(_keySettingLearningLanguage) ?? defaultLearningLanguage;
    notifyListeners();
    log("local app settings loaded");
  }

  void toggleSettingPlayMediaWithSound() async {
    settingPlayMediaWithSound = settingPlayMediaWithSound ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingPlayMediaWithSound, settingPlayMediaWithSound);
    notifyListeners();
  }

  void toggleSettingShowVideoTimeline() async {
    settingShowVideoTimeline = settingShowVideoTimeline ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingShowVideoTimeline, settingShowVideoTimeline);
    notifyListeners();
  }

  void toggleSettingShowMediaOverlay() async {
    settingShowMediaOverlay = settingShowMediaOverlay ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingShowMediaOverlay, settingShowMediaOverlay);
    notifyListeners();
  }

  void toggleSettingUppercase() async {
    settingUppercase = settingUppercase ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingUppercase, settingUppercase);
    notifyListeners();
  }

  void setSettingAppLanguage(String lang) async {
    settingAppLanguage = lang;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettingAppLanguage, settingAppLanguage);
    notifyListeners();
  }

  void setSettingLearningLanguage(String lang) async {
    settingLearningLanguage = lang;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettingLearningLanguage, settingLearningLanguage);
    notifyListeners();
  }

  Future<void> resetLearningProgress() async {
    await _lectureRepository.resetAllVocableProgress();
    log("resetted all vocable progress");
  }

  Future<void> resetAllSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingPlayMediaWithSound, defaultPlayMediaWithSound);
    await prefs.setBool(_keySettingShowVideoTimeline, defaultShowVideoTimeline);
    await prefs.setBool(_keySettingShowMediaOverlay, defaultShowMediaOverlay);
    await prefs.setBool(_keySettingUppercase, defaultUppercase);
    await prefs.setString(_keySettingAppLanguage, defaultAppLanguage);
    await prefs.setString(_keySettingLearningLanguage, defaultLearningLanguage);
    await _loadLocalSettings();
  }
}