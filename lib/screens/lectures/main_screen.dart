import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/screens/lectures/lecture_not_available_screen.dart';
import 'package:lectary/screens/lectures/lecture_screen.dart';


class LectureMainScreen extends StatefulWidget {
  @override
  _LectureMainScreenState createState() => _LectureMainScreenState();
}

class _LectureMainScreenState extends State<LectureMainScreen> {

  // ToDo connect with API
  bool lecturesAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.change_history),
              onPressed: () {
                setState(() {
                  lecturesAvailable = lecturesAvailable ? false : true;
                });
              }
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: lecturesAvailable ? LectureScreen() : LectureNotAvailableScreen(),
    );
  }
}