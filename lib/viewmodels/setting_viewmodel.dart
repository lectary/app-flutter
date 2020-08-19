import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingViewModel with ChangeNotifier {
  static const bool defaultPlayMediaWithSound = true;
  static const bool defaultShowVideoTimeline = true;
  static const bool defaultShowMediaOverlay = true;
  static const bool defaultUppercase = false;
  static const String defaultAppLanguage = "de";
  static const String defaultLearningLanguage = "ALLE"; //TODO for testing purposes

  static const List<String> appLanguagesList = ["de", "en"];
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
      :_lectureRepository = lectureRepository;

  Future<void> loadLocalSettings() async {
    log("loading local app settings");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    settingPlayMediaWithSound = prefs.getBool(_keySettingPlayMediaWithSound) ?? defaultPlayMediaWithSound;
    settingShowVideoTimeline = prefs.getBool(_keySettingShowVideoTimeline) ?? defaultShowVideoTimeline;
    settingShowMediaOverlay = prefs.getBool(_keySettingShowMediaOverlay) ?? defaultShowMediaOverlay;
    settingUppercase = prefs.getBool(_keySettingUppercase) ?? defaultUppercase;
    settingAppLanguage = prefs.getString(_keySettingAppLanguage) ?? defaultAppLanguage;
    settingLearningLanguage = prefs.getString(_keySettingLearningLanguage) ?? defaultLearningLanguage;
  }

  Future<void> toggleSettingPlayMediaWithSound() async {
    settingPlayMediaWithSound = settingPlayMediaWithSound ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingPlayMediaWithSound, settingPlayMediaWithSound);
    notifyListeners();
  }

  Future<void> toggleSettingShowVideoTimeline() async {
    settingShowVideoTimeline = settingShowVideoTimeline ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingShowVideoTimeline, settingShowVideoTimeline);
    notifyListeners();
  }

  Future<void> toggleSettingShowMediaOverlay() async {
    settingShowMediaOverlay = settingShowMediaOverlay ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingShowMediaOverlay, settingShowMediaOverlay);
    notifyListeners();
  }

  Future<void> toggleSettingUppercase() async {
    settingUppercase = settingUppercase ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingUppercase, settingUppercase);
    notifyListeners();
  }

  Future<void> setSettingAppLanguage(String lang) async {
    if (settingAppLanguage == lang) return;
    settingAppLanguage = lang;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettingAppLanguage, settingAppLanguage);
    notifyListeners();
  }

  Future<void> setSettingLearningLanguage(String lang) async {
    settingLearningLanguage = lang;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettingLearningLanguage, settingLearningLanguage);
    notifyListeners();
  }

  Future<void> resetLearningProgress() async {
    log("resetting all vocable progress");
    await _lectureRepository.resetAllVocableProgress();
  }

  Future<void> resetAllSettings() async {
    log("resetting all settings");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySettingPlayMediaWithSound, defaultPlayMediaWithSound);
    await prefs.setBool(_keySettingShowVideoTimeline, defaultShowVideoTimeline);
    await prefs.setBool(_keySettingShowMediaOverlay, defaultShowMediaOverlay);
    await prefs.setBool(_keySettingUppercase, defaultUppercase);
    await prefs.setString(_keySettingAppLanguage, defaultAppLanguage);
    await prefs.setString(_keySettingLearningLanguage, defaultLearningLanguage);
    await loadLocalSettings();
    notifyListeners();
  }
}