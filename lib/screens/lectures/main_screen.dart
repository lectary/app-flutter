import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/screens/lectures/lecture_not_available_screen.dart';
import 'package:lectary/screens/lectures/lecture_screen.dart';
import 'package:lectary/screens/lectures/vocable_search_screen.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


/// Lecture main screen responsible for building the [AppBar] and initially
/// loading all vocables and showing either [LectureScreen] or [LectureNotAvailableScreen]
class LectureMainScreen extends StatefulWidget {
  @override
  _LectureMainScreenState createState() => _LectureMainScreenState();
}

class _LectureMainScreenState extends State<LectureMainScreen> {

  @override
  void initState() {
    Provider.of<CarouselViewModel>(context, listen: false).loadAllVocables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("build lecture-main-screen");
    List<Vocable> vocables = context.select((CarouselViewModel model) => model.currentVocables);

    return Theme(
      data: lectaryThemeDark(),
      child: Scaffold(
        // to avoid bottom overflow when keyboard on search-screen is opened
          resizeToAvoidBottomInset: false,
          appBar: vocables.isNotEmpty
              ? AppBar(
                  title: GestureDetector(
                      child: Text(context.select((CarouselViewModel model) => model.selectionTitle)),
                      onTap: () {
                        Navigator.pushNamed(context, '/search',
                            arguments: VocableSearchScreenArguments(openSearch: false));
                      }),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          Navigator.pushNamed(context, '/search',
                              arguments: VocableSearchScreenArguments(openSearch: true));
                        }),
                  ],
                )
              : AppBar(
                  title: Text(AppLocalizations.of(context).appTitle),
                ),
          drawer: Theme(
            data: lectaryThemeLight(),
            child: MainDrawer(),
          ),
          body: vocables.isNotEmpty
              ? LectureScreen(vocables: vocables)
              : LectureNotAvailableScreen()),
    );
  }
}