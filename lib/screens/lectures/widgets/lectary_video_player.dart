import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';
import 'package:video_player/video_player.dart';

class LectaryVideoPlayer extends StatefulWidget {
  final String videoPath;

  final bool slowMode;
  final bool autoMode;
  final bool loopMode;

  LectaryVideoPlayer({this.videoPath, this.slowMode, this.autoMode, this.loopMode, Key key}) : super(key: key);

  @override
  _LectaryVideoPlayerState createState() => _LectaryVideoPlayerState();
}

class _LectaryVideoPlayerState extends State<LectaryVideoPlayer> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // load video asset and retrieve controller
    _controller = VideoPlayerController.asset(widget.videoPath);
    // init controller content and show first frame via setState()
    _initializeVideoPlayerFuture = _controller.initialize().then((_) => setState((){}));

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: 4/3,
            child: _buildVideoPlayerWithOverlay(),
          );
        } else {
          return AspectRatio(
            aspectRatio: 4/3,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      }
    );
  }

  Widget _buildVideoPlayerWithOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(_controller),
          Visibility(
            visible: !_controller.value.isPlaying,
            child: Container(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.3,
                  child: Icon(Icons.play_circle_filled, size: 120, color: ColorsLectary.white,),
              ),
            ),
          ),
          VideoProgressIndicator(_controller, allowScrubbing: false,
            colors: VideoProgressColors(
              backgroundColor: Color.fromRGBO(0, 0, 0, 0),
              bufferedColor: Color.fromRGBO(0, 0, 0, 0),
              playedColor: ColorsLectary.yellow
            ),
          )
        ],
      ),
    );
  }
}
