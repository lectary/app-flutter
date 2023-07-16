import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/search_result.dart';
import 'package:lectary/models/selection_type.dart';
import 'package:lectary/screens/core/custom_scaffold.dart';
import 'package:lectary/screens/lectures/search/search_result_header.dart';
import 'package:lectary/screens/lectures/search/search_result_row.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:lectary/widgets/custom_search_bar.dart';
import 'package:provider/provider.dart';

/// Used for passing arguments to [VocableSearchScreen] via [Navigator.pushNamed].
class VocableSearchScreenArguments {
  /// Indicates whether the search should be used for navigation only.
  /// This means that the search scope is always the current selection and that no
  /// virtual lecture is created.
  /// Also indicates whether the keyboard should get focus on widget init.
  final bool navigationOnly;

  VocableSearchScreenArguments({required this.navigationOnly});
}

/// Screen for searching for [Vocable].
class VocableSearchScreen extends StatefulWidget {
  static const String routeName = '/search';

  @override
  _VocableSearchScreenState createState() => _VocableSearchScreenState();
}

class _VocableSearchScreenState extends State<VocableSearchScreen> {
  TextEditingController textEditingController = TextEditingController();
  FocusNode focus = FocusNode();

  @override
  void initState() {
    super.initState();

    /// When opening the search-screen, set the current list of [Vocable]
    /// as the init filter result
    Provider.of<CarouselViewModel>(context, listen: false).copyCurrentToFilteredVocables();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    // Retrieving arguments from route
    VocableSearchScreenArguments args =
        ModalRoute.of(context)!.settings.arguments as VocableSearchScreenArguments;
    model.searchForNavigationOnly = args.navigationOnly;
    // listen on changes of the list of filtered vocables
    List<SearchResultItem> searchResults =
        context.select((CarouselViewModel model) => model.searchResults);
    bool uppercase = context.select((SettingViewModel model) => model.settingUppercase);
    Selection? selection = context.select((CarouselViewModel model) => model.currentSelection);

    return Theme(
      data: CustomAppTheme.defaultDarkTheme,
      child: Builder(
        // used to create a new buildContext from which the above new theme is accessible
        builder: (BuildContext context) {
          return CustomScaffold(
            appBarTitle: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                  _getHeaderText(context: context, selection: selection, uppercase: uppercase)),
            ),
            appBarActions: [
              IconButton(
                  icon: Icon(Icons.cancel, semanticLabel: Constants.semanticCloseSearch),
                  onPressed: () {
                    // clearing focus i.e. closing keyboard
                    final FocusScopeNode currentScope = FocusScope.of(context);
                    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                      FocusManager.instance.primaryFocus!.unfocus();
                    }
                    model.clearFilteredVocables(); // clear filter result
                    model
                        .clearAllLocalVocables(); // clear list of all local vocables which is not needed anymore
                    Navigator.pop(context); // close search-screen
                  }),
            ],
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: searchResults.isNotEmpty
                        ? ListView.separated(
                            padding: EdgeInsets.all(0),
                            separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: ColorsLectary.white,
                                ),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final item = searchResults[index];
                              if (item is ItemHeader) {
                                return SearchResultHeader(item.lectureTitle);
                              }
                              if (item is ItemRow) {
                                return SearchResultRow(item.searchResult, textEditingController.text);
                              }
                              throw new Exception("Unsupported type for search result: ${item.runtimeType}");
                            })
                        : Center(
                            child: Text(AppLocalizations.of(context).noVocablesFound,
                                style: Theme.of(context).textTheme.titleMedium),
                          )),
                Column(
                  children: [
                    Divider(height: 1, thickness: 1, color: ColorsLectary.white),
                    CustomSearchBar(
                      textEditingController: textEditingController,
                      focusNode: focus,
                      initOpen: !model.searchForNavigationOnly,
                      filterFunction: model.searchForNavigationOnly
                          ? model.filterVocablesForNavigation
                          : model.filterVocablesForSearch,
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  /// Helper class for extracting correct header text depending on the passed [Selection].
  String _getHeaderText({
    required BuildContext context,
    Selection? selection,
    required bool uppercase,
  }) {
    if (selection == null) return "";
    switch (selection.type) {
      case SelectionType.all:
        return AppLocalizations.of(context).allVocables;
      case SelectionType.package:
        return uppercase ? selection.packTitle!.toUpperCase() : selection.packTitle!;
      case SelectionType.lecture:
        return uppercase ? selection.lesson!.toUpperCase() : selection.lesson!;
      case SelectionType.search:
        return AppLocalizations.of(context).searchLabel +
            (uppercase ? selection.filter!.toUpperCase() : selection.filter!);
      default:
        return "";
    }
  }
}
