import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


/// A custom button that is used for managing the learning progress of a vocable
/// The button displays a number of [Icon], corresponding to the [Vocable.vocableProgress]
/// The [Vocable.vocableProgress] can be changed by pressing the button.
/// The button accepts [size] and [color], used for its size and color
class LearningProgressButton extends StatefulWidget {
  final size;
  final color;

  LearningProgressButton({this.size, this.color});

  @override
  _LearningProgressButtonState createState() => _LearningProgressButtonState();
}

class _LearningProgressButtonState extends State<LearningProgressButton> {
  @override
  Widget build(BuildContext context) {
    int vocableIndex = context.select((CarouselViewModel model) => model.currentItemIndex);
    int progress = context.select((CarouselViewModel model) => model.currentVocables[vocableIndex].vocableProgress);
    return Expanded(
      child: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        color: widget.color,
        child: Container(
          /// additional container for aligning rectangular icons correctly
          width: widget.size.toDouble(),
          child: FittedBox(child: _buildIconsForProgress(progress)),
        ),
        onPressed: () {
          Provider.of<CarouselViewModel>(context, listen: false)
              .currentVocables[vocableIndex]
              .vocableProgress = (progress + 1) % 3;
          setState(() {});
        },
      ),
    );
  }

  Widget _buildIconsForProgress(int progress) {
    switch (progress) {
      case 1:
        return Row(
          children: [
            _buildIcon(),
            _buildIcon()
          ],
        );
      case 2:
        return Column(
          children: [
            _buildIcon(),
            Row(
              children: [
                _buildIcon(),
                _buildIcon()
              ],
            )
          ],
        );
      default:
        return Row(
          children: [
            _buildIcon(),
          ],
        );
    }
  }

  Icon _buildIcon() {
    return Icon(Icons.insert_emoticon, color: ColorsLectary.white);
  }
}
