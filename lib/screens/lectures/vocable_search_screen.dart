import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/search_result.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/screens/lectures/widgets/search_result_package_item.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/widgets/search_bar.dart';
import 'package:provider/provider.dart';

/// Used for passing arguments to [VocableSearchScreen] via [Navigator.pushNamed].
class VocableSearchScreenArguments {
  /// Indicates whether the search should be used for navigation only.
  /// This means that the search scope is always the current selection and that no
  /// virtual lecture is created.
  /// Also indicates whether the keyboard should get focus on widget init.
  final bool navigationOnly;

  VocableSearchScreenArguments({this.navigationOnly});
}


/// Screen for searching for [Vocable].
class VocableSearchScreen extends StatefulWidget {
  static const String routeName  = '/search';

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
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    model.filteredVocables = List.from(model.currentVocables); // create a new! list with model.currentVocables
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    // Retrieving arguments from route
    VocableSearchScreenArguments args = ModalRoute.of(context).settings.arguments;
    model.searchForNavigationOnly = args.navigationOnly;
    // listen on changes of the list of filtered vocables
    List<SearchResultPackage> searchResults = context.select((CarouselViewModel model) => model.searchResults);

    return Theme(
      data: lectaryThemeDark(),
      child: Builder( // used to create a new buildContext from which the above new theme is accessible
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: Text(context.select((CarouselViewModel model) => model.selectionTitle)),
            actions: [
              IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    // clearing focus i.e. closing keyboard
                    final FocusScopeNode currentScope = FocusScope.of(context);
                    if (!currentScope.hasPrimaryFocus &&
                        currentScope.hasFocus) {
                      FocusManager.instance.primaryFocus.unfocus();
                    }
                    model.filteredVocables.clear(); // clear filter result
                    model.clearAllLocalVocables(); // clear list of all local vocables which is not needed anymore
                    Navigator.pop(context); // close search-screen
                  }),
            ],
          ),
          drawer: Theme(
            data: lectaryThemeLight(),
            child: MainDrawer(),
          ),
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
                            return SearchResultPackageItem(context,
                                searchResults[index], textEditingController);
                          })
                      : Center(
                          child: Text(
                              AppLocalizations.of(context).noVocablesFound,
                              style: Theme.of(context).textTheme.subtitle1),
                        )),
              Column(
                children: [
                  Divider(height: 1, thickness: 1, color: ColorsLectary.white),
                  SearchBar(
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
        ),
      ),
    );
  }
}
