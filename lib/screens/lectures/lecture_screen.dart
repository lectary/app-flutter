import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/screens/lectures/widgets/carousel.dart';
import 'package:lectary/screens/lectures/widgets/learning_control_area.dart';
import 'package:lectary/screens/lectures/widgets/media_control_area.dart';
import 'package:lectary/utils/colors.dart';


class LectureScreen extends StatefulWidget {
  final List<Vocable> vocables;

  LectureScreen({this.vocables, Key key}) : super(key: key);

  @override
  _LectureScreenState createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    log("build lecture-screen");

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Stack(children: [
            Carousel(
              key: UniqueKey(),
              vocables: widget.vocables,
              carouselController: carouselController
            ),
            ..._buildCarouselNavigationOverlay(),
          ]),
        ),
        MediaControlArea(flex: 1),
        LearningControlArea(flex: 2, carouselController: carouselController),
      ],
    );
  }

  List<Widget> _buildCarouselNavigationOverlay() {
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: ClipRect(
          child: Align(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.3,
              child: IconButton(
                padding: EdgeInsets.all(0.0),
                iconSize: 60,
                icon: Icon(Icons.keyboard_arrow_left, color: ColorsLectary.white,),
                onPressed: () => carouselController.previousPage(
                  duration: Duration(milliseconds: 300), curve: Curves.linear
                ),
              ),
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: ClipRect(
          child: Align(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.3,
              child: IconButton(
                padding: EdgeInsets.all(0.0),
                iconSize: 60,
                icon: Icon(Icons.keyboard_arrow_right, color: ColorsLectary.white,),
                onPressed: () => carouselController.nextPage(
                    duration: Duration(milliseconds: 300), curve: Curves.linear
                ),
              ),
            ),
          ),
        ),
      )
    ];
  }
}
