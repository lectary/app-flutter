import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/lecture_screen.dart';
import 'package:lectary/utils/colors.dart';
import 'package:provider/provider.dart';

class TextViewer extends StatefulWidget {
  final String content;
  final int mediaIndex;

  final bool slowMode;
  final bool autoMode;
  final bool loopMode;

  final double slowModeSpeed = 0.3;

  TextViewer({this.content, this.mediaIndex, this.slowMode, this.autoMode, this.loopMode, Key key}) : super(key: key);

  @override
  _TextViewerState createState() => _TextViewerState();
}

class _TextViewerState extends State<TextViewer> with TickerProviderStateMixin {
  bool showText = false;
  bool isAutoModeFinished = false;

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
      duration: Duration(seconds: 2),
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CarouselStateProvider carouselStateProvider = Provider.of(context);

    if (!widget.slowMode) {
      _animationController.reset();
      finalContent = widget.content;
    }

    // if current item is not visible any more, reset animation and hide text
    if (carouselStateProvider.currentItemIndex != widget.mediaIndex) {
      showText = false;
      _resetAnimation();
      isAutoModeFinished = false;
      // else start animation and show text automatically and use bool switch for avoiding looping
    } else if (widget.autoMode && !isAutoModeFinished) {
      showText = true;
      _animationController.forward();
      isAutoModeFinished = true;
    }
    return GestureDetector(
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
            aspectRatio: 4 / 3,
            child: showText
                ? Center(
                    child: Text(widget.slowMode ? finalContent : widget.content,
                        style: TextStyle(
                            fontSize: 28, color: ColorsLectary.white)))
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
