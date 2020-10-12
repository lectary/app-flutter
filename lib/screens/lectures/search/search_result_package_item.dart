import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/models/search_result.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';


/// Helper class for realizing categorization of [SearchResult] by [Lecture.lesson].
/// Creates a special [ListTile] header with the lecture name and maps
/// its children list of [SearchResult] to a standard [ListTile].
/// If [showPackage] is false, then the [ListTile] header for the package is omitted.
class SearchResultPackageItem extends StatelessWidget {
  const SearchResultPackageItem({this.context, this.entry, this.textEditingController});

  final BuildContext context;
  final SearchResultPackage entry;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    final settingUppercase = context.select((SettingViewModel model) => model.settingUppercase);
    return _buildTiles(entry, settingUppercase);
  }

  // root level
  Widget _buildTiles(SearchResultPackage pack, bool uppercase) {
    if (pack.children.isEmpty) return ListTile(title: Text(pack.lectureTitle));
    List<Widget> childs = List<Widget>();

    if (entry.lectureTitle.isNotEmpty) {
      childs.add(
        Container(
          alignment: Alignment.centerLeft,
          child: Container(
            color: ColorsLectary.white,
            child: ListTile(
              title: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                    uppercase
                        ? pack.lectureTitle.toUpperCase()
                        : pack.lectureTitle,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorsLectary.lightBlue)),
              ),
            ),
          ),
        ),
      );
    }
    pack.children.map((e) => _buildChildren(e, uppercase)).forEach((element) {childs.addAll(element);});

    Column column = Column(
        children: childs
    );
    return column;
  }

  // children of an package
  List<Widget> _buildChildren(SearchResult searchResult, bool uppercase) {
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    return <Widget>[
      Divider(height: 1,thickness: 1),
      GestureDetector(
        child: ListTile(
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(uppercase
                  ? searchResult.vocable.vocable.toUpperCase()
                  : searchResult.vocable.vocable)),
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
          // When an vocable is tapped, the carousel navigates to it, and creates
          // a new virtual lecture if a "real"-search is performed.
          model.navigateToVocable(searchResult, textEditingController.text);
          // close search-screen
          Navigator.pop(context);
        },
      ),
    ];
  }
}
