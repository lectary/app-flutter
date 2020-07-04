import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/lectary_video_player.dart';
import 'package:lectary/utils/colors.dart';


final List<String> videoList = List.generate(1000, (index) => 'assets/videos/mock_videos/video${(index%3)+1}.mp4');

class LectureScreen extends StatefulWidget {
  @override
  _LectureScreenState createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  bool slowModeOn = false;
  bool autoModeOn = false;
  bool loopModeOn = false;

  bool vocableVisible = false;

  CarouselController carouselController = CarouselController();
  Random random = new Random();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Stack(
            children: [
              CarouselSlider.builder(
                carouselController: carouselController,
                options: CarouselOptions(
                    height: (height / 10) * 7,
                    viewportFraction: 0.999999, // FIXME dirty hack to achieve pre-loading of previous/next page
                    autoPlay: false,
                    enlargeCenterPage: true
                ),
                itemCount: videoList.length,
                itemBuilder: (BuildContext context, int itemIndex) =>
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            child: vocableVisible
                                ? Container(
                              child: Text("Video #$itemIndex", style: TextStyle(color: ColorsLectary.white),), padding: EdgeInsets.all(10),)
                                : IconButton(icon: Icon(Icons.visibility, color: ColorsLectary.green,), iconSize: 60,
                              onPressed: () => setState(() {
                                vocableVisible = vocableVisible ? false : true;
                              }),
                            )
                        ),
                        LectaryVideoPlayer(
                          videoPath: videoList[itemIndex],
                          videoIndex: itemIndex,
                          slowMode: slowModeOn,
                          autoMode: autoModeOn,
                          loopMode: loopModeOn,
                        ),
                      ],
                    ),
              ),
              ..._buildCarouselNavigationOverlay(),
            ]
          ),
        ),
        /// Media Control Area
        Expanded(
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
                  }),
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
        ),
        /// Learning Area
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildButton(
                  ColorsLectary.green,
                  vocableVisible ? Icons.visibility : Icons.visibility_off,
                  70,
                  func: () => setState(() {
                    vocableVisible = vocableVisible ? false : true;
                  })
              ),
              _buildButton(
                  ColorsLectary.violet, Icons.casino,
                  70,
                  func: () => setState(() {
                    int rndPage = random.nextInt(videoList.length);
                    carouselController.jumpToPage(rndPage);
                  })
              ),
              _buildButton(
                  ColorsLectary.lightBlue, Icons.search,
                  70,
                  func: () => setState(() {
                    // TODO search vocable
                  })),
            ],
          ),
        ),
      ],
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

  Expanded _buildButton(color, icon, int size, {int iconContainerWidth=0, Function func=emptyFunction}) {
    return Expanded(
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0))
        ),
        color: color,
        child: Container( /// additional container for aligning rectangular icons correctly
          width: iconContainerWidth == 0 ? size.toDouble() : iconContainerWidth.toDouble(),
          child: Icon(icon, size: size.toDouble(), color: ColorsLectary.white),
        ),
        onPressed: func,
      ),
    );
  }
  static emptyFunction() {}
}