import 'dart:developer' as dev;

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/custom_button.dart';
import 'package:lectary/screens/lectures/widgets/learning_progress_button_animation.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';

/// A [Row] of custom button widgets for controlling some functions in the carousel
/// like visibility of the vocable, navigating to a random vocable and
/// controlling the learning progress
/// Sets and listens for changes in the [CarouselViewModel].
class LearningControlArea extends StatefulWidget {
  final int flex;
  final CarouselController carouselController;

  const LearningControlArea({super.key, required this.flex, required this.carouselController});

  @override
  State<LearningControlArea> createState() => _LearningControlAreaState();
}

class _LearningControlAreaState extends State<LearningControlArea> {
  @override
  Widget build(BuildContext context) {
    dev.log("build learning-control-area");
    final bool hideVocableModeOn =
        context.select((CarouselViewModel model) => model.hideVocableModeOn);
    // Increase icon size on tablets
    final mediaWidth = MediaQuery.of(context).size.width;
    double iconSize = mediaWidth >= Constants.breakpointTablet ? 100 : 70;
    return Expanded(
      flex: widget.flex,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomButton(
            color: ColorsLectary.green,
            iconData: hideVocableModeOn ? Icons.visibility_off : Icons.visibility,
            semanticLabel: hideVocableModeOn ? Constants.semanticShowVocable : Constants.semanticHideVocable,
            iconSize: iconSize,
            func: () => Provider.of<CarouselViewModel>(context, listen: false).hideVocableModeOn =
                hideVocableModeOn ? false : true,
          ),
          CustomButton(
              color: ColorsLectary.violet,
              iconData: Icons.casino,
              semanticLabel: Constants.semanticRandomVocable,
              iconSize: iconSize,
              func: () {
                int rndPage =
                    Provider.of<CarouselViewModel>(context, listen: false).chooseRandomVocable();
                widget.carouselController.jumpToPage(rndPage);
              }),
          // TODO DISABLED FEATURE (LearningProgress)
          // const LearningProgressButtonAnimation()
        ],
      ),
    );
  }
}
