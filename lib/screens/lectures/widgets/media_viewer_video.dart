import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/lecture_screen.dart';
import 'package:lectary/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class LectaryVideoPlayer extends StatefulWidget {
  final String videoPath;
  final int mediaIndex;

  final bool slowMode;
  final bool autoMode;
  final bool loopMode;

  final double slowModeSpeed = 0.3;

  LectaryVideoPlayer({this.videoPath, this.mediaIndex, this.slowMode, this.autoMode, this.loopMode, Key key}) : super(key: key);

  @override
  _LectaryVideoPlayerState createState() => _LectaryVideoPlayerState();
}

class _LectaryVideoPlayerState extends State<LectaryVideoPlayer> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  bool isVideoFinished = false;
  bool isAutoModeFinished = false;
  bool readyForAutoMode = false;

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
    _controller.removeListener(_restartVideoListener);
    _controller.dispose();
    super.dispose();
  }

  /// Listener function for restarting video asynchronously when finished
  void _restartVideoListener() async {
    if (isVideoFinished) return;

    if (_controller.value != null) {
      if ( _controller.value.position >= _controller.value.duration) {
        isVideoFinished = true;

        if (!_controller.value.isPlaying) {
          await _controller.seekTo(Duration.zero);
          await _controller.pause();
          setState(() {
            isVideoFinished = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    CarouselStateProvider carouselStateProvider = Provider.of(context);

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _controller.addListener(_restartVideoListener);

          widget.slowMode ? _controller.setSpeed(widget.slowModeSpeed) : _controller.setSpeed(1);

          widget.loopMode ? _controller.setLooping(true) : _controller.setLooping(false);

          // pauses video if its running but not the current one
          if (carouselStateProvider.currentItemIndex != widget.mediaIndex) {
            isAutoModeFinished = false;
            _controller.pause();
            _controller.seekTo(Duration.zero);
            // check-variable for ensuring that autoMode starts only on swipe in
            readyForAutoMode = widget.autoMode ? true : false;
          // else auto start video and use bool switch for avoiding looping
          } else if (widget.autoMode && readyForAutoMode && !isAutoModeFinished) {
            _controller.play();
            isAutoModeFinished = true;
          }
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
