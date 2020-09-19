import 'package:flutter/material.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';


/// Widget for displaying a [Vocable] of [MediaType.TXT].
/// Hides the media behind an [IconButton] initially, which can be changed by tapping.
/// Uses an [Animation] for an 'slowMode' of the media revealing, where it gets visible continuously over time.
/// For the animation a [StepTween] is used to generate as many ticks as the length of the vocable string, where in each tick,
/// a character from the vocable is randomly chosen and displayed, till the full text is visible.
/// For this, an empty [String] of the same length as the vocable is created as well as an [List] of [int] with the indices
/// of the vocable. Then, on every tick, an index of the list is chosen randomly and used to copy the character at the index of the
/// initial vocable to the empty String, which is then displayed.
/// The animation has a fixed [Duration], so the length of the text string does not influence the length of the animation,
/// but influences the speed of character copying. Thus, a longer text appear to be animated faster.
/// Supports slowMode and autoStarting of the text animation.
class TextViewer extends StatefulWidget {
  final String content;
  final int mediaIndex;

  final bool slowMode;
  final bool autoMode;

  final double slowModeSpeed = Constants.slowModeSpeed;

  TextViewer({this.content, this.mediaIndex, this.slowMode, this.autoMode, Key key}) : super(key: key);

  @override
  _TextViewerState createState() => _TextViewerState();
}

class _TextViewerState extends State<TextViewer> with TickerProviderStateMixin {
  bool showText = false;
  /// Used for indicating if animation is played once due to autoMode for avoiding looping.
  bool isAutoModeFinished = false;
  /// Used for ensuring the animation is only auto-played on swipe in.
  /// E.g. for avoiding that the animation is played when pressing autoPlay
  bool readyForAutoMode = false;

  AnimationController _animationController;
  Animation<int> _characterCount;

  String finalContent;
  int index = -1;
  List<int> randomBox;

  @override
  void initState() {
    super.initState();
    // placeholder of empty chars that get replaced during the animation
    finalContent = " " * widget.content.length;
    // array of indices representing the content, to pick one index randomly
    randomBox = List.generate(widget.content.length, (_index) => _index);

    _animationController = AnimationController(
      duration: Duration(milliseconds: Constants.mediaAnimationDurationMilliseconds),
      vsync: this,
    );
    _characterCount = StepTween(begin: 0, end: widget.content.length-1).animate(_animationController)
      ..addListener(() {
        // update only when index changed
        if (index < _characterCount.value) {
          index = _characterCount.value;
          randomBox.shuffle();
          int rndIndex = randomBox.removeLast();
          setState(() {
            finalContent = finalContent.replaceRange(rndIndex, rndIndex+1, widget.content[rndIndex]);
          });
        }
      });
    readyForAutoMode = widget.autoMode ? true : false;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // listening on the index of the current visible carousel page/item
    int currentItemIndex = context.select((CarouselViewModel model) => model.currentItemIndex);
    bool uppercase = context.select((SettingViewModel model) => model.settingUppercase);
    bool interrupted = context.select((CarouselViewModel model) => model.interrupted);

    // if slowMode gets disabled the media gets visible instantly
    if (!widget.slowMode) {
      _animationController.reset();
      finalContent = widget.content;
    }
    // if current item is not visible any more, reset animation and hide text
    if (currentItemIndex != widget.mediaIndex || interrupted) {
      showText = false;
      _resetAnimation();
      isAutoModeFinished = false;
      // check-variable for ensuring that autoMode starts only on swipe in
      readyForAutoMode = widget.autoMode ? true : false;
      // else start animation and show text automatically and use isAutoModeFinished
      // bool switch for avoiding looping
    } else if (widget.autoMode && readyForAutoMode && !isAutoModeFinished) {
      showText = true;
      _animationController.forward();
      // play animation only once due to autoMode to avoid looping
      isAutoModeFinished = true;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // ensures that the whole area can be tapped, not only the area containing the child widget
      onTap: () {
        setState(() {
          if (widget.slowMode) {
            if (showText) {
              _resetAnimation();
            } else {
              _resetAnimation();
              _animationController.forward();
            }
          }
          showText = showText ? false : true;
        });
      },
      child: Center(
        child: AspectRatio(
            aspectRatio: Constants.aspectRatio,
            child: showText
                ? Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(50),
                    child: Text(
                      uppercase
                          ? (widget.slowMode
                              ? finalContent.toUpperCase()
                              : widget.content.toUpperCase())
                          : (widget.slowMode ? finalContent : widget.content),
                      style:
                          TextStyle(fontSize: 28, color: ColorsLectary.white),
                      textAlign: TextAlign.center,
                    ))
                : Icon(
                    Icons.subject,
                    size: 120,
                  )),
      ),
    );
  }

  void _resetAnimation() {
    _animationController.reset();
    finalContent = " " * widget.content.length;
    index = -1;
    randomBox = List.generate(widget.content.length, (_index) => _index);
  }
}
