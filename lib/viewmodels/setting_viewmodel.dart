import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lectary_overview.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingViewModel with ChangeNotifier {
  bool settingAppFreshInstalled = Constants.defaultAppFreshInstalled;
  bool settingPlayMediaWithSound = Constants.defaultPlayMediaWithSound;
  bool settingShowVideoTimeline = Constants.defaultShowVideoTimeline;
  bool settingShowMediaOverlay = Constants.defaultShowMediaOverlay;
  bool settingUppercase = Constants.defaultUppercase;
  String settingAppLanguage = Constants.defaultAppLanguage;
  String settingLearningLanguage = Constants.defaultLearningLanguage;
  List<String> learningLanguagesList = Constants.defaultLearningLanguagesList;

  /// Status indicator used for showing progress-indicator while updating
  /// learning languages
  bool _isUpdatingLanguages = false;
  bool get isUpdatingLanguages => _isUpdatingLanguages;

  final LectureRepository _lectureRepository;

  SettingViewModel({required lectureRepository})
      :_lectureRepository = lectureRepository {
    log("settings instance created");
    loadLocalSettings();
  }

  Future<void> loadLocalSettings() async {
    log("loading local app settings");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    settingAppFreshInstalled = prefs.getBool(Constants.keySettingAppFreshInstalled) ?? Constants.defaultAppFreshInstalled;
    settingPlayMediaWithSound = prefs.getBool(Constants.keySettingPlayMediaWithSound) ?? Constants.defaultPlayMediaWithSound;
    settingShowVideoTimeline = prefs.getBool(Constants.keySettingShowVideoTimeline) ?? Constants.defaultShowVideoTimeline;
    settingShowMediaOverlay = prefs.getBool(Constants.keySettingShowMediaOverlay) ?? Constants.defaultShowMediaOverlay;
    settingUppercase = prefs.getBool(Constants.keySettingUppercase) ?? Constants.defaultUppercase;
    settingAppLanguage = prefs.getString(Constants.keySettingAppLanguage) ?? Constants.defaultAppLanguage;
    settingLearningLanguage = prefs.getString(Constants.keySettingLearningLanguage) ?? Constants.defaultLearningLanguage;
    learningLanguagesList = prefs.getStringList(Constants.keySettingLearningLanguageList) ?? List.from(Constants.defaultLearningLanguagesList);
    learningLanguagesList.sort((a,b) => Utils.customCompareTo(a, b));
  }

  Future<void> updateLearningLanguages() async {
    _isUpdatingLanguages = true;
    notifyListeners();

    // adding all media languages to a hashSet to avoid duplicates
    HashSet<String> availableLanguages = HashSet();
    // loading all languages based on remote availability
    LectaryData data = await _lectureRepository.loadLectaryData();
    data.lessons.forEach((lesson) => availableLanguages.add(lesson.langMedia.toUpperCase()));

    // loading all languages based on local lectures
    HashSet<String> localLanguagesOfLectures = HashSet();
    List<Lecture> lectures = await _lectureRepository.loadLecturesLocal();
    lectures.forEach((lecture) => localLanguagesOfLectures.add(lecture.langMedia.toUpperCase()));

    // merging language-lists
    List<String> mergedList = localLanguagesOfLectures.toList();
    availableLanguages.forEach((lang) {
      if (!mergedList.contains(lang)) {
        mergedList.add(lang);
      }
    });

    // considering default languages
    Constants.defaultLearningLanguagesList.forEach((lang) {
      if (!mergedList.contains(lang)) {
        mergedList.add(lang);
      }
    });

    // sort
    mergedList.sort();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(Constants.keySettingLearningLanguageList, mergedList);
    learningLanguagesList = mergedList;

    _isUpdatingLanguages = false;
    notifyListeners();
  }

  Future<void> setSettingAppFreshInstalled(bool freshInstalled) async {
    settingAppFreshInstalled = freshInstalled;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.keySettingAppFreshInstalled, settingAppFreshInstalled);
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