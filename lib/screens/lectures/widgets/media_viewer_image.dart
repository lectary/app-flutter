import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


/// Widget for displaying a [Vocable] of [MediaType.PNG] or [MediaType.JPG].
/// Hides the media behind an [IconButton] initially, which can be changed by tapping.
/// Uses an [Animation] for an 'slowMode' of the media revealing, where it gets visible continuously over time.
/// For the animation a [Tween] of type [Double] is used to animate values in a specific range, which are then
/// used in an [BackdropFilter] of type [ImageFilter.blur] to control the intensity of the blur.
/// Supports slowMode and autoStarting of the image animation.
class ImageViewer extends StatefulWidget {
  final String imagePath;
  final int mediaIndex;

  final bool slowMode;
  final bool autoMode;

  final double slowModeSpeed = Constants.slowModeSpeed;

  ImageViewer({this.imagePath, this.mediaIndex, this.slowMode, this.autoMode, Key key}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with TickerProviderStateMixin {
  bool showPicture = false;
  /// Used for indicating if animation is played once due to autoMode for avoiding looping.
  bool isAutoModeFinished = false;
  /// Used for ensuring the animation is only auto-played on swipe in.
  /// E.g. for avoiding that the animation is played when pressing autoPlay
  bool readyForAutoMode = false;

  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: Constants.mediaAnimationDurationMilliseconds),
      vsync: this,
    );
    _animation = Tween<double>(begin: 50, end: 0).animate(_animationController)
    ..addListener(() {
      // update ui on every tick
      setState(() {});
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

    // if slowMode gets disabled the media gets visible instantly
    if (!widget.slowMode) {
      _animationController.reset();
    }
    // if current item is not visible any more, reset animation and hide image
    if (currentItemIndex != widget.mediaIndex) {
      showPicture = false;
      _animationController.reset();
      isAutoModeFinished = false;
      // check-variable for ensuring that autoMode starts only on swipe in
      readyForAutoMode = widget.autoMode ? true : false;
      // else show image (and in case of slow mode start the animation) automatically
      // and use isAutoModeFinished bool switch for avoiding looping
    } else if (widget.autoMode && readyForAutoMode && !isAutoModeFinished) {
      if (widget.slowMode) {
        _animationController.forward();
      }
      showPicture = true;
      // play animation only once due to autoMode to avoid looping
      isAutoModeFinished = true;
    }
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
            aspectRatio: Constants.aspectRatio,
            child: showPicture
                ? Stack(alignment: Alignment.bottomCenter, children: [
                    Image.file(File(widget.imagePath)),
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
