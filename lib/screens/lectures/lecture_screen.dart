import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';
import 'package:video_player/video_player.dart';


final List<String> videoList = [
  'assets/videos/mock_videos/video1.mp4',
  'assets/videos/mock_videos/video2.mp4',
  'assets/videos/mock_videos/video3.mp4',
];


class LectureScreen extends StatefulWidget {
  @override
  _LectureScreenState createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  bool slowModeOn = false;
  bool autoModeOn = false;
  bool repeatModeOn = false;
  bool vocableVisible = false;

  VideoPlayerController _controller1;
  VideoPlayerController _controller2;
  VideoPlayerController _controller3;
  Future<void> _initializeVideoPlayerFuture1;
  Future<void> _initializeVideoPlayerFuture2;
  Future<void> _initializeVideoPlayerFuture3;

  @override
  void initState() {
    // Create and store the VideoPlayerController
    _controller1 = VideoPlayerController.asset(videoList[0]);
    _controller2= VideoPlayerController.asset(videoList[1]);
    _controller3 = VideoPlayerController.asset(videoList[2]);

    _initializeVideoPlayerFuture1 = _controller1.initialize().then((value) => setState(() {}));
    _controller1.setLooping(true);
    _controller1.play();
    _initializeVideoPlayerFuture2 = _controller2.initialize().then((value) => setState(() {}));
    _controller2.setLooping(true);
    _controller2.play();
    _initializeVideoPlayerFuture3 = _controller3.initialize().then((value) => setState(() {}));
    _controller3.setLooping(true);
    _controller3.play();

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();

    super.dispose();
  }

  Widget _buildVideoFuture(_initializeVideoPlayerFuture, _controller) {
    return FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(_controller),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          child: (vocableVisible ? Text('Vokabel') : Icon(Icons.visibility, size: 80, color: ColorsLectary.green,)),
        ),
        // FIXME Videoplayer
        Container(
          height: 300,
          color: Colors.grey,
          child: CarouselSlider(
              options: CarouselOptions(
              autoPlay: false,
              enlargeCenterPage: true,
              ),
              items: [
                _buildVideoFuture(_initializeVideoPlayerFuture1, _controller1),
                _buildVideoFuture(_initializeVideoPlayerFuture2, _controller2),
                _buildVideoFuture(_initializeVideoPlayerFuture3, _controller3)],
        ),
        ),
        /// First button row for setting different video modes
        Container(
          height: 60,
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
                  (repeatModeOn ? ColorsLectary.red : ColorsLectary.darkBlue),
                  IconData(0xe902, fontFamily: 'icomoon'),
                  35,
                  func: () => setState(() {
                    repeatModeOn = repeatModeOn ? false : true;
                  })
              ),
            ],
          ),
        ),
        /// second button row for setting different vocable selection (modes)
        Container(
          height: 120,
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
                    // TODO select vocable randomly
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