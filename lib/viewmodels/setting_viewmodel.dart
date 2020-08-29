import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lectary_overview.dart';
import 'package:lectary/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingViewModel with ChangeNotifier {
  bool settingPlayMediaWithSound = Constants.defaultPlayMediaWithSound;
  bool settingShowVideoTimeline = Constants.defaultShowVideoTimeline;
  bool settingShowMediaOverlay = Constants.defaultShowMediaOverlay;
  bool settingUppercase = Constants.defaultUppercase;
  String settingAppLanguage = Constants.defaultAppLanguage;
  String settingLearningLanguage = Constants.defaultLearningLanguage;
  List<String> learningLanguagesList = Constants.defaultLearningLanguagesList;

  bool _isUpdatingLanguages = false;
  bool get isUpdatingLanguages => _isUpdatingLanguages;

  final LectureRepository _lectureRepository;

  SettingViewModel({@required lectureRepository})
      :_lectureRepository = lectureRepository;

  Future<void> loadLocalSettings() async {
    log("loading local app settings");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    settingPlayMediaWithSound = prefs.getBool(Constants.keySettingPlayMediaWithSound) ?? Constants.defaultPlayMediaWithSound;
    settingShowVideoTimeline = prefs.getBool(Constants.keySettingShowVideoTimeline) ?? Constants.defaultShowVideoTimeline;
    settingShowMediaOverlay = prefs.getBool(Constants.keySettingShowMediaOverlay) ?? Constants.defaultShowMediaOverlay;
    settingUppercase = prefs.getBool(Constants.keySettingUppercase) ?? Constants.defaultUppercase;
    settingAppLanguage = prefs.getString(Constants.keySettingAppLanguage) ?? Constants.defaultAppLanguage;
    settingLearningLanguage = prefs.getString(Constants.keySettingLearningLanguage) ?? Constants.defaultLearningLanguage;
    learningLanguagesList = prefs.getStringList(Constants.keySettingLearningLanguageList) ?? Constants.defaultLearningLanguagesList;
  }

  Future<void> updateLearningLanguages() async {
    _isUpdatingLanguages = true;
    notifyListeners();

    // adding all media languages to a hashSet to avoid duplicates
    HashSet<String> availableLanguages = HashSet();
    LectaryData data = await _lectureRepository.loadLectaryData();
    data.lessons.forEach((lesson) => availableLanguages.add(lesson.langMedia));
    //TODO 'ALLE' for testing purposes - maybe remove
    List<String> newLanguages = List.of({"ALLE", ...availableLanguages.toList()});
    newLanguages.sort();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(Constants.keySettingLearningLanguageList, newLanguages);
    learningLanguagesList = newLanguages;

    _isUpdatingLanguages = false;
    notifyListeners();
  }

  Future<void> toggleSettingPlayMediaWithSound() async {
    settingPlayMediaWithSound = settingPlayMediaWithSound ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.keySettingPlayMediaWithSound, settingPlayMediaWithSound);
    notifyListeners();
  }

  Future<void> toggleSettingShowVideoTimeline() async {
    settingShowVideoTimeline = settingShowVideoTimeline ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.keySettingShowVideoTimeline, settingShowVideoTimeline);
    notifyListeners();
  }

  Future<void> toggleSettingShowMediaOverlay() async {
    settingShowMediaOverlay = settingShowMediaOverlay ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.keySettingShowMediaOverlay, settingShowMediaOverlay);
    notifyListeners();
  }

  Future<void> toggleSettingUppercase() async {
    settingUppercase = settingUppercase ? false : true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.keySettingUppercase, settingUppercase);
    notifyListeners();
  }

  Future<void> setSettingAppLanguage(String lang) async {
    if (settingAppLanguage == lang) return;
    settingAppLanguage = lang;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.keySettingAppLanguage, settingAppLanguage);
    notifyListeners();
  }

  Future<void> setSettingLearningLanguage(String lang) async {
    settingLearningLanguage = lang;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.keySettingLearningLanguage, settingLearningLanguage);
    notifyListeners();
  }

  Future<void> resetLearningProgress() async {
    log("resetting all vocable progress");
    await _lectureRepository.resetAllVocableProgress();
  }

  Future<void> resetAllSettings() async {
    log("resetting all settings");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.keySettingPlayMediaWithSound, Constants.defaultPlayMediaWithSound);
    await prefs.setBool(Constants.keySettingShowVideoTimeline, Constants.defaultShowVideoTimeline);
    await prefs.setBool(Constants.keySettingShowMediaOverlay, Constants.defaultShowMediaOverlay);
    await prefs.setBool(Constants.keySettingUppercase, Constants.defaultUppercase);
    await prefs.setString(Constants.keySettingAppLanguage, Constants.defaultAppLanguage);
    await prefs.setString(Constants.keySettingLearningLanguage, Constants.defaultLearningLanguage);
    await loadLocalSettings();
    notifyListeners();
  }
}