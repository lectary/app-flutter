import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/core/custom_scaffold.dart';
import 'package:lectary/screens/lectures/lecture_not_available_screen.dart';
import 'package:lectary/screens/lectures/lecture_screen.dart';
import 'package:lectary/screens/lectures/lecture_startup_screen.dart';
import 'package:lectary/screens/lectures/search/vocable_search_screen.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/models/selection_type.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';


/// Lecture main screen responsible for building the [AppBar] and initially
/// loading all vocables and showing either [LectureScreen] or [LectureNotAvailableScreen].
class LectureMainScreen extends StatelessWidget {
  static const String routeName  = '/';

  const LectureMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("build lecture-main-screen--theme");
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    Future<List<Vocable>> vocableFuture = model.initVocables();
    model.listenOnLocalLectures();
    return Theme(
      data: CustomAppTheme.defaultDarkTheme,
      // Future builder will wait till the vocables are loaded initially, then the snapshot
      // stays the same and we are constantly in the first if-branch. On vocable updates
      // only the builder function of the FutureBuilder will be called.
      child: FutureBuilder(
          future: vocableFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              // retrieve current vocable list and keep listening for future changes in the vocable selection
              List<Vocable> vocables = context.select((CarouselViewModel model) => model.currentVocables);
              bool uppercase = context.select((SettingViewModel model) => model.settingUppercase);
              Selection? selection = context.select((CarouselViewModel model) => model.currentSelection);
              bool freshAppInstallation = Provider.of<SettingViewModel>(context, listen: false).settingAppFreshInstalled;
              log("build lecture-main-screen--lectures");
              return CustomScaffold(
                  resizeToAvoidBottomInset: false,
                  appBarTitle: vocables.isNotEmpty
                      ? _buildAppBarTitle(context, selection, uppercase)
                      : Text(AppLocalizations.of(context).appTitle),
                  appBarActions: vocables.isNotEmpty ? _buildAppBarActions(selection, context) : [],
                  body: vocables.isNotEmpty
                      ? LectureScreen(vocables: vocables)
                      : freshAppInstallation
                          ? const LectureStartupScreen()
                          : const LectureNotAvailableScreen());
            } else {
              log("build lecture-main-screen--loading");
              return CustomScaffold(
                  resizeToAvoidBottomInset: false,
                  appBarTitle: Text(AppLocalizations.of(context).appTitle),
                  body: const Center(child: CircularProgressIndicator()));
            }
          }),
    );
  }

  List<Widget> _buildAppBarActions(Selection? selection, BuildContext context) {
    return [
      selection!.type == SelectionType.search
          ? IconButton(
              icon: const Icon(
                Icons.close,
                semanticLabel: Constants.semanticCloseVirtualLecture,
              ),
              onPressed: () =>
                  Provider.of<CarouselViewModel>(context, listen: false).closeVirtualLecture())
          : IconButton(
              icon: const Icon(
                Icons.search,
                semanticLabel: Constants.semanticSearch,
              ),
              onPressed: () {
                Navigator.pushNamed(context, VocableSearchScreen.routeName,
                    arguments: VocableSearchScreenArguments(navigationOnly: false));
              }),
    ];
  }

  GestureDetector _buildAppBarTitle(BuildContext context, Selection? selection, bool uppercase) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  _getHeaderText(context: context, selection: selection, uppercase: uppercase),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, VocableSearchScreen.routeName,
              arguments: VocableSearchScreenArguments(navigationOnly: true));
        });
  }

  /// Helper class for extracting correct header text depending on the passed [Selection].
  String _getHeaderText({required BuildContext context, Selection? selection, required bool uppercase}) {
    if (selection == null) return "";
    switch (selection.type) {
      case SelectionType.all:
        return AppLocalizations.of(context).allVocables;
      case SelectionType.package:
        return uppercase ? selection.packTitle!.toUpperCase() : selection.packTitle!;
      case SelectionType.lecture:
        return uppercase ? selection.lesson!.toUpperCase() : selection.lesson!;
      case SelectionType.search:
        return AppLocalizations.of(context).searchLabel + (uppercase ? selection.filter!.toUpperCase() : selection.filter!);
      default:
        return "";
    }
  }
}