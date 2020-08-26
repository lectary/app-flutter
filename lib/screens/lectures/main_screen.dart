import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/screens/lectures/lecture_not_available_screen.dart';
import 'package:lectary/screens/lectures/lecture_screen.dart';
import 'package:lectary/screens/lectures/search/vocable_search_screen.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


/// Lecture main screen responsible for building the [AppBar] and initially
/// loading all vocables and showing either [LectureScreen] or [LectureNotAvailableScreen]
class LectureMainScreen extends StatefulWidget {
  static const String routeName  = '/';

  @override
  _LectureMainScreenState createState() => _LectureMainScreenState();
}

class _LectureMainScreenState extends State<LectureMainScreen> {
  Future<List<Vocable>> _vocableFuture;
  List<Vocable> vocables;

  @override
  void initState() {
    _vocableFuture = Provider.of<CarouselViewModel>(context, listen: false).loadAllVocables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("build lecture-main-screen--theme");
    return Theme(
      data: lectaryThemeDark(),
      // Future builder will wait till the vocables are loaded initially, then the snapshot
      // stays the same and we are constantly in the first if-branch. On vocable updates
      // only the builder function of the FutureBuilder will be called.
      child: FutureBuilder(
          future: _vocableFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              // retrieve current vocable list and keep listening for future changes in the vocable selection
              vocables = context.select((CarouselViewModel model) => model.currentVocables);
              log("build lecture-main-screen--lectures");
              return Scaffold(
                  // to avoid bottom overflow when keyboard on search-screen is opened
                  resizeToAvoidBottomInset: false,
                  appBar: vocables.isNotEmpty
                      ? AppBar(
                          title: GestureDetector(
                              child: Text(context.select((CarouselViewModel model) => model.selectionTitle)),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, VocableSearchScreen.routeName,
                                    arguments: VocableSearchScreenArguments(
                                        navigationOnly: true));
                              }),
                          actions: [
                            IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, VocableSearchScreen.routeName,
                                      arguments: VocableSearchScreenArguments(
                                          navigationOnly: false));
                                }),
                          ],
                        )
                      : AppBar(title: Text(AppLocalizations.of(context).appTitle),),
                  drawer: Theme(
                    data: lectaryThemeLight(),
                    child: MainDrawer(),
                  ),
                  body: vocables.isNotEmpty
                      ? LectureScreen(vocables: vocables)
                      : LectureNotAvailableScreen());
            } else {
              log("build lecture-main-screen--loading");
              return Scaffold(
                  // to avoid bottom overflow when keyboard on search-screen is opened
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: Text(AppLocalizations.of(context).appTitle),
                  ),
                  drawer: Theme(
                    data: lectaryThemeLight(),
                    child: MainDrawer(),
                  ),
                  body: Center(child: CircularProgressIndicator()));
            }
          }),
    );
  }
}