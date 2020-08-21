import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';


/// Widget for displaying a [Vocable] of [MediaType.MP4].
/// Custom video player wrapper around the [VideoPlayer] plugin for extended functionality.
/// Supports lopping, slowMode and autoStarting of videos.
class LectaryVideoPlayer extends StatefulWidget {
  final String videoPath;
  final int mediaIndex;

  final bool slowMode;
  final bool autoMode;
  final bool loopMode;

  final double slowModeSpeed = Constants.slowModeSpeed;

  LectaryVideoPlayer({this.videoPath, this.mediaIndex, this.slowMode, this.autoMode, this.loopMode, Key key}) : super(key: key);

  @override
  _LectaryVideoPlayerState createState() => _LectaryVideoPlayerState();
}

class _LectaryVideoPlayerState extends State<LectaryVideoPlayer> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  bool isVideoFinished = false;
  /// Used for indicating if video is played once due to autoMode for avoiding looping.
  bool isAutoModeFinished = false;
  /// Used for ensuring the video is only auto-played on swipe in.
  /// E.g. for avoiding that video is played when pressing autoPlay
  bool readyForAutoMode = false;

  @override
  void initState() {
    // loads the video asset and retrieves a controller
    _controller = VideoPlayerController.file(File(widget.videoPath));
    // init controller content and show first frame via setState()
    _initializeVideoPlayerFuture = _controller.initialize().then((_) => setState((){}));
    readyForAutoMode = widget.autoMode ? true : false;
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_restartVideoListener);
    _controller.dispose();
    super.dispose();
  }

  /// Listener function for resetting video asynchronously when finished
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
    // listening on the index of the current visible carousel page/item
    int currentItemIndex = context.select((CarouselViewModel model) => model.currentItemIndex);
    // Setting volume corresponding to app-setting
    if (context.select((SettingViewModel model) => model.settingPlayMediaWithSound)) {
      _controller.setVolume(1);
    } else {
      _controller.setVolume(0);
    }
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _controller.addListener(_restartVideoListener);

          widget.slowMode ? _controller.setSpeed(widget.slowModeSpeed) : _controller.setSpeed(1);
          widget.loopMode ? _controller.setLooping(true) : _controller.setLooping(false);

          // resets video if its running but its not the current visible one in the carousel
          if (currentItemIndex != widget.mediaIndex) {
            isAutoModeFinished = false;
            _controller.pause();
            _controller.seekTo(Duration.zero);
            // check-variable for ensuring that autoMode starts only on swipe in
            readyForAutoMode = widget.autoMode ? true : false;
          // else auto start video and use bool switch for avoiding looping
          } else if (widget.autoMode && readyForAutoMode && !isAutoModeFinished) {
            _controller.play();
            // play video only once due to autoMode to avoid looping
            isAutoModeFinished = true;
          }
          return AspectRatio(
            aspectRatio: Constants.aspectRatio,
            child: _buildVideoPlayerWithOverlay(context),
          );
        } else {
          return AspectRatio(
            aspectRatio: Constants.aspectRatio,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      }
    );
  }

  // custom overlay for the video player displaying a play button and a video timeline
  Widget _buildVideoPlayerWithOverlay(BuildContext context) {
    bool isOverlayOn = context.select((SettingViewModel model) => model.settingShowMediaOverlay);
    bool isVideoTimelineOn = context.select((SettingViewModel model) => model.settingShowVideoTimeline);
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
            visible: isOverlayOn && !_controller.value.isPlaying,
            child: Container(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.3,
                  child: Icon(Icons.play_circle_filled, size: 120, color: ColorsLectary.white,),
              ),
            ),
          ),
          Visibility(
            visible: isVideoTimelineOn,
            child: VideoProgressIndicator(_controller, allowScrubbing: false,
              colors: VideoProgressColors(
                backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                bufferedColor: Color.fromRGBO(0, 0, 0, 0),
                playedColor: ColorsLectary.yellow
              ),
            ),
          )
        ],
      ),
    );
  }
}
