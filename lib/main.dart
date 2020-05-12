import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lectary/i18n/localizations.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LectaryMainPage(),
    );
  }
}

class LectaryMainPage extends StatelessWidget {
  LectaryMainPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).emptyLectures,
            ),
          ],
        ),
      ),
    );
  }
}