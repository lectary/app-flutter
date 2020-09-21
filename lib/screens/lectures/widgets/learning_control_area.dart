import 'dart:developer' as dev;
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/learning_progress_button_animation.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:lectary/screens/lectures/widgets/custom_button.dart';


/// A [Row] of custom button widgets for controlling some functions in the carousel
/// like visibility of the vocable, navigating to a random vocable and
/// controlling the learning progress
/// Sets and listens for changes in the [CarouselViewModel].
class LearningControlArea extends StatefulWidget {
  final int flex;
  final CarouselController carouselController;

  LearningControlArea({this.flex, this.carouselController});

  @override
  _LearningControlAreaState createState() => _LearningControlAreaState();
}

class _LearningControlAreaState extends State<LearningControlArea> {

  @override
  Widget build(BuildContext context) {
    dev.log("build learning-control-area");
    final bool hideVocableModeOn =
        context.select((CarouselViewModel model) => model.hideVocableModeOn);

    return Expanded(
      flex: widget.flex,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomButton(
            color: ColorsLectary.green,
            icon: hideVocableModeOn ? Icons.visibility_off : Icons.visibility,
            semanticLabel: hideVocableModeOn ? Constants.semanticShowVocable : Constants.semanticHideVocable,
            size: 70,
            func: () => Provider.of<CarouselViewModel>(context, listen: false)
                .hideVocableModeOn = hideVocableModeOn ? false : true,
          ),
          CustomButton(
            color: ColorsLectary.violet,
            icon: Icons.casino,
            semanticLabel: Constants.semanticRandomVocable,
            size: 70,
            func: () {
              int rndPage = Provider.of<CarouselViewModel>(context, listen: false).chooseRandomVocable();
              widget.carouselController.jumpToPage(rndPage);
            }
          ),
          LearningProgressButtonAnimation()
        ],
      ),
    );
  }
}
