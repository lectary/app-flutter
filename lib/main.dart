import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/about/about_screen.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/screens/lectures/search/vocable_search_screen.dart';
import 'package:lectary/screens/management/lecture_management_screen.dart';
import 'package:lectary/screens/settings/settings_screen.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:lectary/data/api/lectary_api.dart';
import 'package:lectary/data/db/database.dart';


/// Entry point, opens and loads an instance of the database provided by [DatabaseProvider]
/// and runs [LectaryApp]
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await DatabaseProvider.instance.db;

  runApp(LectaryApp(lectureDatabase: database));
}


/// This first widget is the root of the application and responsible for creating all needed providers
/// Providers in usage: [SettingViewModel], [LectureViewModel], [CarouselViewModel]
/// Retrieves the instance of the [LectureDatabase]
class LectaryApp extends StatelessWidget {
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
          create: (BuildContext context) { return null; },
          update: (context, lectureRepository, settingViewModel) =>
              SettingViewModel(lectureRepository: lectureRepository),
          lazy: false,
        ),
        ChangeNotifierProxyProvider2<LectureRepository, SettingViewModel, LectureViewModel>(
          create: (BuildContext context) { return null; },
          update: (context, lectureRepository, settingViewModel, lectureViewModel) =>
              LectureViewModel(lectureRepository: lectureRepository, settingViewModel: settingViewModel),
        ),
        ChangeNotifierProxyProvider2<LectureRepository, SettingViewModel, CarouselViewModel>(
          create: (BuildContext context) { return null; },
          update: (context, lectureRepository, settingViewModel, carouselViewModel) =>
              CarouselViewModel(lectureRepository: lectureRepository, settingViewModel: settingViewModel),
        )
      ],
      child: LocalizedApp(),
    );
  }
}


/// This widget encapsulates the localization logic and the [MaterialApp]
/// Provides a static [setLocale] method for changing the locale everywhere in the app
class LocalizedApp extends StatefulWidget {
  const LocalizedApp({
    Key key,
  }) : super(key: key);

  @override
  _LocalizedAppState createState() => _LocalizedAppState();

  /// Static method for changing the [Locale] by finding [_LocalizedAppState] via [BuildContext]
  /// from everywhere in the app and setting a new locale, which rebuilds the entire application.
  /// Also loads all application settings via [SettingViewModel] on initialization
  static void setLocale(BuildContext context, Locale newLocale) {
    _LocalizedAppState state = context.findAncestorStateOfType();
    state.setState(() {
      state.locale = newLocale;
    });
  }
}

class _LocalizedAppState extends State<LocalizedApp> {
  Locale locale;

  @override
  void initState() {
    super.initState();
    // loading all application settings and setting the locale
    final settings = Provider.of<SettingViewModel>(context, listen: false);
    settings.loadLocalSettings().then((_) {
      setState(() {
        String lang = settings.settingAppLanguage;
        this.locale = Locale(lang, '');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // restricting device orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (locale == null) {
      return CircularProgressIndicator();
    } else {
      return MaterialApp(
          onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appTitle, // used by os task switcher
          locale: locale,
          localizationsDelegates: [
            AppLocalizations.delegate, // custom localization
            GlobalMaterialLocalizations.delegate, // provides localized values for the material component library
            GlobalWidgetsLocalizations.delegate, // defines text direction (right2left/left2right)
            GlobalCupertinoLocalizations.delegate, // ios
          ],
          supportedLocales: [
            const Locale('de', ''),
            const Locale('en', ''),
          ],
          theme: lectaryThemeLight(),
          initialRoute: LectureMainScreen.routeName,
          routes: {
            LectureMainScreen.routeName: (context) => LectureMainScreen(),
            VocableSearchScreen.routeName: (context) => VocableSearchScreen(),
            LectureManagementScreen.routeName : (context) => LectureManagementScreen(),
            SettingsScreen.routeName: (context) => SettingsScreen(),
            AboutScreen.routeName: (context) => AboutScreen(),
          }
      );
    }
  }
}