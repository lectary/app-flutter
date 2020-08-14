import 'dart:math';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lectary/models/media_item.dart';
import 'package:lectary/screens/lectures/widgets/carousel.dart';
import 'package:lectary/screens/lectures/widgets/learning_progress_button.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


class LectureScreen extends StatefulWidget {

  final List<MediaItem> items;

  LectureScreen({this.items, Key key}) : super(key: key);

  @override
  _LectureScreenState createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  bool slowModeOn = false;
  bool autoModeOn = false;
  bool loopModeOn = false;
  bool hideVocableModeOn = false;
  UniqueKey _key;

  CarouselController carouselController = CarouselController();
  Random random = new Random();

  void _rebuildCarousel() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  void didChangeDependencies() {
    bool selectionDidUpdate = Provider.of<CarouselViewModel>(context).selectionDidUpdate;
    if (selectionDidUpdate) {
      Provider.of<CarouselViewModel>(context, listen: false).selectionDidUpdate = false;
      _rebuildCarousel();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    /// main widget tree - carousel, media-control-area, learning-area
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Stack(children: [
            Carousel(
              key: _key,
              items: widget.items,
              carouselController: carouselController,
              slowModeOn: slowModeOn,
              autoModeOn: autoModeOn,
              loopModeOn: loopModeOn,
              hideVocableModeOn: hideVocableModeOn,
            ),
            ..._buildCarouselNavigationOverlay(),
          ]),
        ),
        _buildMediaControlArea(),
        _buildLearningArea(),
      ],
    );
  }

  Widget _buildMediaControlArea() {
    return Expanded(
      flex: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildButton(
              (slowModeOn ? ColorsLectary.yellow : ColorsLectary.darkBlue),
              IconData(0xe900, fontFamily: 'icomoon'),
              35,
              func: () => setState(() {
                slowModeOn = slowModeOn ? false : true;
              })
          ),
          _buildButton(
              (autoModeOn ? ColorsLectary.orange : ColorsLectary.darkBlue),
              IconData(0xe901, fontFamily: 'icomoon'),
              35,
              iconContainerWidth: 80, // extra container size for aligning rectangular icon correctly
              func: () => setState(() {
                autoModeOn = autoModeOn ? false : true;
              })
          ),
          _buildButton(
              (loopModeOn ? ColorsLectary.red : ColorsLectary.darkBlue),
              IconData(0xe902, fontFamily: 'icomoon'),
              35,
              func: () => setState(() {
                loopModeOn = loopModeOn ? false : true;
              })
          ),
        ],
      ),
    );
  }

  Widget _buildLearningArea() {
    return Expanded(
      flex: 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildButton(
            ColorsLectary.green,
            hideVocableModeOn ? Icons.visibility_off : Icons.visibility,
            70,
            iconColor: hideVocableModeOn ? ColorsLectary.white : Colors.grey[600],
            func: () => setState(() {
              hideVocableModeOn = hideVocableModeOn ? false : true;
            }),
          ),
          _buildButton(
              ColorsLectary.violet, Icons.casino,
              70,
              func: () => setState(() {
                int rndPage = random.nextInt(Provider.of<CarouselViewModel>(context, listen: false).currentMediaItems.length);
                Provider.of<CarouselViewModel>(context, listen: false).currentItemIndex = rndPage;
                carouselController.jumpToPage(rndPage);
              })
          ),
          LearningProgressButton(size: 70, color: ColorsLectary.lightBlue)
        ],
      ),
    );
  }

  List<Widget> _buildCarouselNavigationOverlay() {
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: ClipRect(
          child: Align(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.3,
              child: IconButton(
                padding: EdgeInsets.all(0.0),
                iconSize: 60,
                icon: Icon(Icons.keyboard_arrow_left, color: ColorsLectary.white,),
                onPressed: () => carouselController.previousPage(
                  duration: Duration(milliseconds: 300), curve: Curves.linear
                ),
              ),
            ),
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: ClipRect(
          child: Align(
            widthFactor: 0.5,
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.3,
              child: IconButton(
                padding: EdgeInsets.all(0.0),
                iconSize: 60,
                icon: Icon(Icons.keyboard_arrow_right, color: ColorsLectary.white,),
                onPressed: () => carouselController.nextPage(
                    duration: Duration(milliseconds: 300), curve: Curves.linear
                ),
              ),
            ),
          ),
        ),
      )
    ];
  }

  /// common button widget with style, used in the lecture screen
  Expanded _buildButton(color, icon, int size, {Color iconColor=ColorsLectary.white, int iconContainerWidth=0, Function func=emptyFunction}) {
    return Expanded(
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0))
        ),
        color: color,
        child: Container( /// additional container for aligning rectangular icons correctly
          width: iconContainerWidth == 0 ? size.toDouble() : iconContainerWidth.toDouble(),
          child: Icon(icon, size: size.toDouble(), color: iconColor),
        ),
        onPressed: func,
      ),
    );
  }
  static emptyFunction() {}
}
