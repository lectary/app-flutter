import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/learning_progress_button.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


/// Class for handling the [Animation] of showing and hiding the learning-progress-button
/// Uses a [SizeTransition] and a [CurvedAnimation] with [Curves.fastOutSlowIn] for showing and hiding the button via tap on the
/// arrow-button on the side.
class LearningProgressButtonAnimation extends StatefulWidget {
  @override
  _LearningProgressButtonAnimationState createState() => _LearningProgressButtonAnimationState();
}

class _LearningProgressButtonAnimationState extends State<LearningProgressButtonAnimation> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  bool _buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    // controls the animation and sets its duration
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500)
    );
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
                Container(
                  // the size needs to be set manually
                  width: widthButton,
                  child: LearningProgressButton(
                      size: 70, color: ColorsLectary.lightBlue),
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
                  padding: EdgeInsets.all(0.0),
                  iconSize: widthControl * 2,
                  icon: _buttonEnabled
                      ? Icon(
                          Icons.keyboard_arrow_right,
                          color: ColorsLectary.white,
                        )
                      : Icon(
                          Icons.keyboard_arrow_left,
                          color: ColorsLectary.white,
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
