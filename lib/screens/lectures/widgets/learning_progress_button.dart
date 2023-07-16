import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


/// A custom button that is used for managing the learning progress of a vocable
/// The button displays a number of [Icon], corresponding to the [Vocable.vocableProgress]
/// The [Vocable.vocableProgress] can be changed by pressing the button.
/// The button accepts [iconSize] and [color], used for its size and color
class LearningProgressButton extends StatefulWidget {
  final double iconSize;
  final Color color;

  const LearningProgressButton({required this.iconSize, required this.color, super.key});

  @override
  State<LearningProgressButton> createState() => _LearningProgressButtonState();
}

class _LearningProgressButtonState extends State<LearningProgressButton> {

  @override
  Widget build(BuildContext context) {
    int vocableIndex = context.select((CarouselViewModel model) => model.currentItemIndex);
    // check first if list is not empty
    int progress = context.select((CarouselViewModel model) {
      if (model.currentVocables.isNotEmpty) {
        return model.currentVocables[vocableIndex].vocableProgress;
      } else {
        return 0;
      }
    });
    return MergeSemantics(
      child: Semantics(
        label: Constants.semanticLearningProgress + (progress + 1).toString(),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: widget.color,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
          ),
          child: SizedBox(
            /// additional container for aligning rectangular icons correctly
            width: widget.iconSize,
            child: FittedBox(child: _buildIconsForProgress(progress)),
          ),
          onPressed: () {
            Provider.of<CarouselViewModel>(context, listen: false).increaseVocableProgress(vocableIndex);
          },
        ),
      ),
    );
  }

  // returns a column with a nested row with the correct icons corresponding
  // to the progress, which results in a pyramid like arrangement
  Widget _buildIconsForProgress(int progress) {
    switch (progress) {
      case 1:
        return Column(
          children: [
            _buildIcon(false),
            Row(
              children: [
                _buildIcon(true),
                _buildIcon(true)
              ],
            )
          ],
        );
      case 2:
        return Column(
          children: [
            _buildIcon(true),
            Row(
              children: [
                _buildIcon(true),
                _buildIcon(true)
              ],
            )
          ],
        );
      default:
        return Column(
          children: [
            _buildIcon(false),
            Row(
              children: [
                _buildIcon(true),
                _buildIcon(false)
              ],
            )
          ],
        );
    }
  }

  // returns either a circle or smiley widget
  Icon _buildIcon(bool filled) {
    return filled
        ? const Icon(Icons.insert_emoticon, color: ColorsLectary.white)
        : const Icon(Icons.radio_button_unchecked, color: ColorsLectary.white);
  }
}
