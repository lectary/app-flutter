import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/models/search_result.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';

class SearchResultPackageItem extends StatelessWidget {
  const SearchResultPackageItem(this.context, this.entry, this.textEditingController);

  final BuildContext context;
  final SearchResultPackage entry;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }

  // root level
  Widget _buildTiles(SearchResultPackage pack) {
    if (pack.children.isEmpty) return ListTile(title: Text(pack.lectureTitle));
    List<Widget> childs = List<Widget>();
    childs.add(
      Container(
        //padding: EdgeInsets.only(left: 15, top: 5, bottom: 5),
        alignment: Alignment.centerLeft,
        //child: Text(pack.title, style: Theme.of(context).textTheme.caption))
        child: Container(
          color: ColorsLectary.white,
          child: ListTile(
            title: Text(pack.lectureTitle, style: Theme.of(context).textTheme.caption),
          ),
        ),
      ),
    );
    pack.children.map(_buildChildren).forEach((element) {childs.addAll(element);});

    Column column = Column(
        children: childs
    );
    return column;
  }

  // children of an package
  List<Widget> _buildChildren(SearchResult searchResult) {
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    return <Widget>[
      Divider(height: 1,thickness: 1),
      GestureDetector(
        child: ListTile(
            title: Text(searchResult.vocable.vocable),
            trailing: (() {
              if (searchResult.mediaType == null) return SizedBox();
              MediaType mediaType = MediaType.fromString(searchResult.mediaType);
              switch (mediaType) {
                case MediaType.PNG:
                case MediaType.JPG:
                  return Icon(Icons.insert_photo);
                case MediaType.MP4:
                  return Icon(Icons.movie);
                case MediaType.TXT:
                  return Icon(Icons.subject);
                default: return SizedBox();
              }
            })(),
        ),
        onTap: () {
          int newIndex = model.getIndexOfResult(searchResult);
          if (textEditingController.text.isNotEmpty) {
            // if search-term is not empty, a new "virtual"-lecture
            // containing the filter results is created and set
            log("Created new virtual lecture");
            model.selectionTitle = "Suche: " + textEditingController.text;
            model.createNewVirtualLecture();
            // set index corresponding to the tabbed item index where
            // the carouselController should jump to after init
            //model.currentItemIndex = index;
            model.currentItemIndex = newIndex;
          } else {
            // Jump to page (vocable) if search-term is empty
            model.carouselController.jumpToPage(newIndex);
          }
          // close search-screen
          Navigator.pop(context);
        },
      ),
    ];
  }
}
