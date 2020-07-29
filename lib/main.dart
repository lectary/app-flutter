import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/about/about_screen.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/screens/management/lecture_management_screen.dart';
import 'package:lectary/screens/settings/settings_screen.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:provider/provider.dart';

import 'data/api/lectary_api.dart';
import 'data/db/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await DatabaseProvider.instance.db;

  runApp(LectaryApp(lectureDatabase: database));
}

class LectaryApp extends StatelessWidget {
  // This widget is the root of your application.
  final LectureDatabase lectureDatabase;

  LectaryApp({this.lectureDatabase});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: LectaryApi()),
        ProxyProvider<LectaryApi, LectureRepository>(
          update: (context, lectaryApi, lectureRepository) =>
              LectureRepository(lectaryApi: lectaryApi, lectureDatabase: lectureDatabase),
          dispose: (context, lectureRepository) => lectureRepository.dispose(),
        ),
        ChangeNotifierProxyProvider<LectureRepository, LectureViewModel>(
          update: (context, lectureRepository, lectureViewModel) =>
              LectureViewModel(lectureRepository: lectureRepository),
          create: (BuildContext context) { return null; },
        )
      ],
      child: MaterialApp(
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
        theme: lectaryThemeLight(),
        initialRoute: '/',
        routes: {
          '/': (context) => LectureMainScreen(),
          '/lectureManagement': (context) => LectureManagementScreen(),
          '/settings': (context) => SettingsScreen(),
          '/about': (context) => AboutScreen(),
        }
      ),
    );
  }
}