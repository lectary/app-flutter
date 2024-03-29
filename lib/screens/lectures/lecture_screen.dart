import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/screens/lectures/widgets/carousel.dart';
import 'package:lectary/screens/lectures/widgets/carousel_navigation_overlay.dart';
import 'package:lectary/screens/lectures/widgets/learning_control_area.dart';
import 'package:lectary/screens/lectures/widgets/media_control_area.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';

/// Lecture screen in case there are available [Vocable].
/// Consists of the [Carousel] with its [CarouselNavigationOverlay],
/// and the two control areas [MediaControlArea] and [LearningControlArea].
class LectureScreen extends StatefulWidget {
  final List<Vocable> vocables;

  const LectureScreen({required this.vocables, Key? key}) : super(key: key);

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  CarouselController carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    // Setting controller in the viewModel to provide access and navigation possibilities for other screens, i.e. VocableSearchScreen
    Provider.of<CarouselViewModel>(context, listen: false).carouselController = carouselController;
  }

  @override
  Widget build(BuildContext context) {
    log("build lecture-screen");
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Stack(
            children: [
              Carousel(
                  key: UniqueKey(),
                  vocables: widget.vocables,
                  carouselController: carouselController),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AspectRatio(
                    aspectRatio: Constants.aspectRatio,
                    child: CarouselNavigationOverlay(carouselController: carouselController)),
              )
            ],
          ),
        ),
        const MediaControlArea(flex: 1),
        LearningControlArea(flex: 2, carouselController: carouselController),
      ],
    );
  }
}
