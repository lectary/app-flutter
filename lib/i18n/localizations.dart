import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:lectary/i18n/localizations_strings.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';

/// Class for handling localization resources
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  static bool _settingUppercase;

  static AppLocalizations of(BuildContext context) {
    _settingUppercase = Provider.of<SettingViewModel>(context, listen: false).settingUppercase;
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // uses string-mapping defined in localizations_strings.dart
  static Map<String, Map<String, String>> _localizedValues = {
    'de': de,
    'en': en,
  };

  // Getters for localized values
  _getValue(String key) {
    String value = _localizedValues[locale.languageCode][key] ?? "<no translation>";
    return _settingUppercase
        ? value.toUpperCase()
        : value;
  }

  String get appTitle => _getValue(AppTitle);
  String get emptyLectures => _getValue(EmptyLectures);
  String get minMaxLectureSizes => _getValue(MinMaxLectureSizes);
  String get downloadAndManageLectures => _getValue(DownloadAndManageLectures);
  String get screenManagementTitle => _getValue(ScreenManagementTitle);
  String get screenManagementSearchHint => _getValue(ScreenManagementSearchHint);
  String get screenSettingsTitle => _getValue(ScreenSettingsTitle);
  String get screenAboutTitle => _getValue(ScreenAboutTitle);
  String get okUppercase => _getValue(OkUppercase);
  String get cancel => _getValue(Cancel);
  String get download => _getValue(Download);
  String get update => _getValue(Update);
  String get delete => _getValue(Delete);
  String get noDescription => _getValue(NoDescription);
  String get close => _getValue(Close);
  String get oops => _getValue(Oops);
  String get reportErrorText => _getValue(ReportErrorText);
  String get reportError => _getValue(ReportError);

  String get errorDownloadLecture => _getValue(ErrorDownloadLecture);

  String get lectureInfoLecture => _getValue(LectureInfoLecture);
  String get lectureInfoPack => _getValue(LectureInfoPack);
  String get lectureInfoFileSize => _getValue(LectureInfoFileSize);
  String get lectureInfoVocableCount => _getValue(LectureInfoVocableCount);
  String get lectureInfoFileSizeUnit => _getValue(LectureInfoFileSizeUnit);

  String get drawerHeader => _getValue(DrawerHeader);
  String get drawerButtonLectureManagement => _getValue(DrawerButtonLectureManagement);
  String get drawerButtonSettings => _getValue(DrawerButtonSettings);
  String get drawerAllVocables => _getValue(DrawerAllVocables);
  String get drawerNoLecturesAvailable => _getValue(DrawerNoLecturesAvailable);

  String get noLecturesFound => _getValue(NoLecturesFound);
  String get deleteAllLectures => _getValue(DeleteAllLectures);
  String get deleteAllLecturesQuestion => _getValue(DeleteAllLecturesQuestion);
  String get deleteAll => _getValue(DeleteAll);
  String get deletingLectures => _getValue(DeletingLectures);

  String get noInternetConnection => _getValue(NoInternetConnection);
  String get offlineMode => _getValue(OfflineMode);

  String get aboutIntroductionPart1 => _getValue(AboutIntroductionPart1);
  String get aboutIntroductionPart2 => _getValue(AboutIntroductionPart2);
  String get aboutContact => _getValue(AboutContact);
  String get aboutInstruction => _getValue(AboutInstruction);
  String get aboutCredits => _getValue(AboutCredits);
  String get aboutIconCredit => _getValue(AboutIconCredit);
  String get aboutIconCreationCreditPart1 => _getValue(AboutIconCreationCreditPart1);
  String get aboutIconCreationCreditPart2 => _getValue(AboutIconCreationCreditPart2);
  String get aboutVersion => _getValue(AboutVersion);
}

/// Bridge-class for flutter i18n mechanics and custom i18n resource class.
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale('de', ''),
      Locale('en', ''),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}