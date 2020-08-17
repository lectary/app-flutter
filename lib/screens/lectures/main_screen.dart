import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/screens/lectures/lecture_not_available_screen.dart';
import 'package:lectary/screens/lectures/lecture_screen.dart';
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
    log("build lecture-main-screen");
    List<Vocable> vocables = context.select((CarouselViewModel model) => model.currentVocables);

    return Theme(
      data: lectaryThemeDark(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(context.select((CarouselViewModel model) => model.selectionTitle)),
          ),
          drawer: Theme(
            data: lectaryThemeLight(),
            child: MainDrawer(),
          ),
          body: vocables.isNotEmpty
              ? LectureScreen(vocables: vocables)
              : LectureNotAvailableScreen()),
    );
  }
}