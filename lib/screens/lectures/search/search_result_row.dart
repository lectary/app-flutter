import 'package:flutter/material.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/models/search_result.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';

class SearchResultRow extends StatelessWidget {
  final SearchResult searchResult;
  final String searchString;

  const SearchResultRow(this.searchResult, this.searchString, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingUppercase = context.select((SettingViewModel model) => model.settingUppercase);
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    return GestureDetector(
      child: ListTile(
        title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(settingUppercase
                ? searchResult.vocable.vocable.toUpperCase()
                : searchResult.vocable.vocable)),
        trailing: (() {
          final mediaTypeString = searchResult.mediaType;
          if (mediaTypeString == null) return SizedBox();
          MediaType mediaType = MediaType.fromString(mediaTypeString);
          switch (mediaType) {
            case MediaType.PNG:
            case MediaType.JPG:
              return Icon(Icons.insert_photo);
            case MediaType.MP4:
              return Icon(Icons.movie);
            case MediaType.TXT:
              return Icon(Icons.subject);
            default:
              return SizedBox();
          }
        })(),
      ),
      onTap: () {
        // When an vocable is tapped, the carousel navigates to it, and creates
        // a new virtual lecture if a "real"-search is performed.
        model.navigateToVocable(searchResult, searchString);
        // close search-screen
        Navigator.pop(context);
      },
    );
  }
}
