import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';

class ImageViewer extends StatefulWidget {
  final String picturePath;
  final int pictureIndex;

  final bool slowMode;
  final bool autoMode;
  final bool loopMode;

  final double slowModeSpeed = 0.3;

  ImageViewer({this.picturePath, this.pictureIndex, this.slowMode, this.autoMode, this.loopMode, Key key}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with TickerProviderStateMixin {
  bool showPicture = false;

  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 50, end: 0).animate(_animationController)
    ..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.slowMode) {
            showPicture
                ? _animationController.reset()
                : _animationController.forward();
          }
          showPicture = showPicture ? false : true;
        });
      },
      child: Center(
        child: AspectRatio(
            aspectRatio: 4 / 3,
            child: showPicture
                ? Stack(children: [
                    Image.asset(widget.picturePath),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaY: _animation.status == AnimationStatus.forward
                              ? _animation.value
                              : 0,
                          sigmaX: _animation.status == AnimationStatus.forward
                              ? _animation.value
                              : 0,
                        ),
                        child: Container(
                          color: ColorsLectary.darkBlue.withOpacity(0),
                        ),
                      ),
                    ),
                  ])
                : Icon(
                    Icons.image,
                    size: 120,
                  )),
      ),
    );
  }
}
