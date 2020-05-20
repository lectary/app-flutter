import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:lectary/i18n/localizations_strings.dart';

/// Class for handling localization resources
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // uses string-mapping defined in localizations_strings.dart
  static Map<String, Map<String, String>> _localizedValues = {
    'de': de,
  };

  // Getters for localized values
  _getValue(String key) => _localizedValues[locale.languageCode][key];

  String get appTitle => _getValue(AppTitle);
  String get emptyLectures => _getValue(EmptyLectures);
  String get minMaxLectureSizes => _getValue(MinMaxLectureSizes);
  String get downloadAndManageLectures => _getValue(DownloadAndManageLectures);
  String get buttonLectureManagement => _getValue(ButtonLectureManagement);
  String get buttonSettings => _getValue(ButtonSettings);
  String get screenManagementTitle => _getValue(ScreenManagementTitle);
  String get screenManagementSearchHint => _getValue(ScreenManagementSearchHint);
  String get screenSettingsTitle => _getValue(ScreenSettingsTitle);
  String get screenAboutTitle => _getValue(ScreenAboutTitle);
}

/// Bridge-class for flutter i18n mechanics and custom i18n resource class.
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale('de', 'DE'),
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