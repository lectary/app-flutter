import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/about/about_screen.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/screens/management/lecture_management_screen.dart';
import 'package:lectary/screens/settings/settings_screen.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
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
        Provider(create: (context) => LectaryApi()),
        ProxyProvider<LectaryApi, LectureRepository>(
          update: (context, lectaryApi, lectureRepository) =>
              LectureRepository(lectaryApi: lectaryApi, lectureDatabase: lectureDatabase),
          //dispose: (context, lectureRepository) => lectureRepository.dispose(), //TODO-Review: disable for enabling hot reload, maybe reactivate for production?
        ),
        ChangeNotifierProxyProvider<LectureRepository, SettingViewModel>(
          update: (context, lectureRepository, settingViewModel) => SettingViewModel(lectureRepository: lectureRepository),
          create: (BuildContext context) { return null; },
          lazy: false,
        ),
        ChangeNotifierProxyProvider2<LectureRepository, SettingViewModel, LectureViewModel>(
          update: (context, lectureRepository, settingViewModel, lectureViewModel) =>
              LectureViewModel(lectureRepository: lectureRepository, settingViewModel: settingViewModel),
          create: (BuildContext context) { return null; },
        ),
        ChangeNotifierProxyProvider<LectureRepository, CarouselViewModel>(
          update: (context, lectureRepository, carouselViewModel) =>
              CarouselViewModel(lectureRepository: lectureRepository),
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