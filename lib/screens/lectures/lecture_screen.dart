import 'dart:math';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer.dart';
import 'package:lectary/utils/colors.dart';
import 'package:provider/provider.dart';

abstract class MediaItem {
  final String text;
  final String media;

  MediaItem(this.text, this.media);
}

class VideoItem extends MediaItem {
  VideoItem({String text, String media}) : super(text, media);
}

class PictureItem extends MediaItem {
  PictureItem({String text, String media}) : super(text, media);

}

class TextItem extends MediaItem {
  TextItem({String text, String media}) : super(text, media);
}

final mediaList = List<MediaItem>.generate(50, (index) => index % 3 == 0
    ? VideoItem(text: "Media #$index - Vocable 1", media: 'assets/videos/mock_videos/video1.mp4')
    : (index % 3 == 1
    ? PictureItem(text: "Media #$index - Mushroom", media: 'assets/pictures/mock_pictures/mushroom.jpg')
    : TextItem(text: "Media #$index - Vocable", media: "Vocabulario"))
);


final List<String> videoList = List.generate(1000, (index) => 'assets/videos/mock_videos/video${(index%3)+1}.mp4');

/// helper class to keep track of current item
class CarouselStateProvider with ChangeNotifier {
  int _currentItemIndex = 0;

  int get currentItemIndex => _currentItemIndex;

  set currentItemIndex(int currentItemIndex) {
    _currentItemIndex = currentItemIndex;
    notifyListeners();
  }
}


class LectureScreen extends StatefulWidget {
  @override
  _LectureScreenState createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  bool slowModeOn = false;
  bool autoModeOn = false;
  bool loopModeOn = false;
  bool hideVocableModeOn = false;

  CarouselController carouselController = CarouselController();
  Random random = new Random();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    /// main widget tree - carousel, media-control-area, learning-area
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
                    enlargeCenterPage: true,
                    initialPage: 0,
                    onPageChanged: (int index, CarouselPageChangedReason reason) {
                      Provider.of<CarouselStateProvider>(context, listen: false).currentItemIndex = index;
                    }
                ),
                itemCount: mediaList.length,
                itemBuilder: (BuildContext context, int itemIndex) =>
                    /// media viewer - types: video, image, text
                    MediaViewer(
                        mediaItem: mediaList[itemIndex],
                        mediaIndex: itemIndex,
                        hideVocableModeOn: hideVocableModeOn,
                        slowModeOn: slowModeOn,
                        autoModeOn: autoModeOn,
                        loopModeOn: loopModeOn),
              ),
              ..._buildCarouselNavigationOverlay(),
            ]
          ),
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
                int rndPage = random.nextInt(videoList.length);
                Provider.of<CarouselStateProvider>(context, listen: false).currentItemIndex = rndPage;
                carouselController.jumpToPage(rndPage);
              })
          ),
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
