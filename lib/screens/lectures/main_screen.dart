import 'package:flutter/material.dart';
import 'package:lectary/models/media_item.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/screens/lectures/lecture_not_available_screen.dart';
import 'package:lectary/screens/lectures/lecture_screen.dart';
import 'package:lectary/screens/lectures/vocable_search_screen.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


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
    List<MediaItem> items = context.select((CarouselViewModel model) => model.currentMediaItems);

    return Theme(
      data: lectaryThemeDark(),
      child: Scaffold(
          resizeToAvoidBottomInset: false, // to avoid bottom overflow when keyboard on search-screen is opened
          appBar: AppBar(
            title: GestureDetector(
                child: Text(context
                    .select((CarouselViewModel model) => model.selectionTitle)),
                onTap: () {
                  Navigator.pushNamed(context, '/search',
                      arguments:
                          VocableSearchScreenArguments(openSearch: false));
                }),
            actions: [
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.pushNamed(context, '/search',
                        arguments:
                            VocableSearchScreenArguments(openSearch: true));
                  }),
            ],
          ),
          drawer: Theme(
            data: lectaryThemeLight(),
            child: MainDrawer(),
          ),
          body: items.isNotEmpty
              ? LectureScreen(items: items)
              : LectureNotAvailableScreen()),
    );
  }
}