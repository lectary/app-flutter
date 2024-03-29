import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/learning_progress_button.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';

/// Class for handling the [Animation] of showing and hiding the learning-progress-button
/// Uses a [SizeTransition] and a [CurvedAnimation] with [Curves.fastOutSlowIn] for showing and hiding the button via tap on the
/// arrow-button on the side.
class LearningProgressButtonAnimation extends StatefulWidget {
  const LearningProgressButtonAnimation({super.key});

  @override
  State<LearningProgressButtonAnimation> createState() => _LearningProgressButtonAnimationState();
}

class _LearningProgressButtonAnimationState extends State<LearningProgressButtonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    // controls the animation and sets its duration
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    // defines the kind of animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _buttonEnabled ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    double width = MediaQuery.of(context).size.width;
    // used for aligning progress button and button for enabling
    width = width / 3;
    final double widthButton = width * 0.8;
    final double widthControl = width * 0.2;
    // Increase icon size on tablets
    final mediaWidth = MediaQuery.of(context).size.width;
    double iconSize = mediaWidth >= Constants.breakpointTablet ? 100 : 70;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizeTransition(
            axis: Axis.horizontal,
            axisAlignment: 0,
            sizeFactor: _animation,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  // the size needs to be set manually
                  width: widthButton,
                  child: LearningProgressButton(iconSize: iconSize, color: ColorsLectary.lightBlue),
                ),
              ],
            )),
        Container(
          color: ColorsLectary.lightBlue,
          child: ClipRect(
            child: Align(
              widthFactor: 0.5,
              alignment: Alignment.center,
              child: IconButton(
                  padding: const EdgeInsets.all(0.0),
                  iconSize: widthControl * 2,
                  icon: _buttonEnabled
                      ? const Icon(
                          Icons.keyboard_arrow_right,
                          color: ColorsLectary.white,
                          semanticLabel: Constants.semanticDeactivateLearningProgress,
                        )
                      : const Icon(
                          Icons.keyboard_arrow_left,
                          color: ColorsLectary.white,
                          semanticLabel: Constants.semanticActivateLearningProgress,
                        ),
                  onPressed: () {
                    setState(() {
                      if (_buttonEnabled) {
                        _controller.reverse();
                        _buttonEnabled = false;
                        model.vocableProgressEnabled = false;
                      } else {
                        _controller.forward();
                        _buttonEnabled = true;
                        model.vocableProgressEnabled = true;
                      }
                    });
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
