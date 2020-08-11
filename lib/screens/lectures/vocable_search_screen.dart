import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/models/media_item.dart';
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


class VocableSearchScreen extends StatefulWidget {
  @override
  _VocableSearchScreenState createState() => _VocableSearchScreenState();
}

class _VocableSearchScreenState extends State<VocableSearchScreen> {
  TextEditingController textEditingController = TextEditingController();
  FocusNode focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    // Retrieving arguments from route
    final VocableSearchScreenArguments args = ModalRoute.of(context).settings.arguments;
    List<MediaItem> filteredVocables = context.select((CarouselViewModel model) => model.currentMediaItems);

    return Theme(
      data: lectaryThemeDark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context
              .select((CarouselViewModel model) => model.selectionTitle)),
          actions: [
            IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  // clearing focus i.e. closing keyboard
                  final FocusScopeNode currentScope = FocusScope.of(context);
                  if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                    FocusManager.instance.primaryFocus.unfocus();
                  }
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
                  separatorBuilder: (context, index) => Divider(
                        color: ColorsLectary.white,
                      ),
                  itemCount: filteredVocables.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredVocables[index].text),
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
