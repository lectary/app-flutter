import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/widgets/search_bar.dart';
import 'package:provider/provider.dart';

/// Used for passing arguments to [VocableSearchScreen] via [Navigator.pushNamed]
class VocableSearchScreenArguments {
  /// Indicates whether search and keyboard should get focus on widget init
  final bool openSearch;

  VocableSearchScreenArguments({this.openSearch});
}


/// Screen for searching for [Vocable].
class VocableSearchScreen extends StatefulWidget {
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
    model.filteredVocables = List.from(model.currentVocables); // create a new list with model.currentVocables
  }

  @override
  Widget build(BuildContext context) {
    // Retrieving arguments from route
    final VocableSearchScreenArguments args = ModalRoute.of(context).settings.arguments;
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    // listen on changes of the list of filtered vocables
    List<Vocable> filteredVocables = context.select((CarouselViewModel model) => model.filteredVocables);

    return Theme(
      data: lectaryThemeDark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.select((CarouselViewModel model) => model.selectionTitle)),
          actions: [
            IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  // clearing focus i.e. closing keyboard
                  final FocusScopeNode currentScope = FocusScope.of(context);
                  if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                    FocusManager.instance.primaryFocus.unfocus();
                  }
                  // clear filter result and close search-screen
                  model.filteredVocables.clear();
                  Navigator.pop(context);
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
              child: ListView.separated(
                  padding: EdgeInsets.all(0),
                  separatorBuilder: (context, index) => Divider(color: ColorsLectary.white,),
                  itemCount: filteredVocables.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        child: ListTile(
                          title: Text(filteredVocables[index].vocable,),
                        ),
                        onTap: () {
                          if (textEditingController.text.isNotEmpty) {
                            // if search-term is not empty, a new "virtual"-lecture
                            // containing the filter results is created and set
                            log("Created new virtual lecture");
                            model.selectionTitle = "Suche: " + textEditingController.text;
                            model.currentVocables = List.from(model.filteredVocables);
                            // set index corresponding to the tabbed item index where
                            // the carouselController should jump to after init
                            model.currentItemIndex = index;
                          } else {
                            // Jump to page (vocable) if search-term is empty
                            model.carouselController.jumpToPage(index);
                          }
                          // close search-screen
                          Navigator.pop(context);
                        },
                    );
                  }),
            ),
            Column(
              children: [
                Divider(height: 1, thickness: 1, color: ColorsLectary.white),
                SearchBar(
                  textEditingController: textEditingController,
                  focusNode: focus,
                  initOpen: args.openSearch,
                  filterFunction:
                      Provider.of<CarouselViewModel>(context, listen: false)
                          .filterVocables,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
