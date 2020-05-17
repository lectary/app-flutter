import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/utils/global_theme.dart';

void main() {
  runApp(LectaryApp());
}

class LectaryApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appTitle, // used by os task switcher
      localizationsDelegates: [
        AppLocalizations.delegate, // custom localization
        GlobalMaterialLocalizations.delegate, // provides localized values for the material component library
        GlobalWidgetsLocalizations.delegate, // defines text direction (right2left/left2right)
        GlobalCupertinoLocalizations.delegate, // ios
      ],
      supportedLocales: [
        const Locale('de', 'DE'),
      ],
      theme: LectaryTheme(),
      home: LectureMainScreen(),
    );
  }
}