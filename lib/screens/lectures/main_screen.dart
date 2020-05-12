import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/no_lectures_available_screen.dart';
import 'package:lectary/screens/lectures/lecture_screen.dart';

class LectureMainScreen extends StatelessWidget {
  LectureMainScreen({Key key}) : super(key: key);

  // ToDo connect with API
  final bool lecturesAvailable = false;

  @override
  Widget build(BuildContext context) {
    return lecturesAvailable ? LectureScreen() : NoLecturesAvailableScreen();
  }
}