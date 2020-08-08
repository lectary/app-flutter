import 'package:flutter/material.dart';
import 'package:lectary/models/media_item.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer_image.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer_text.dart';

import 'media_viewer_text_area.dart';
import 'media_viewer_video.dart';

class MediaViewer extends StatelessWidget {
  const MediaViewer({
    Key key,
    @required this.mediaItem,
    @required this.mediaIndex,
    @required this.hideVocableModeOn,
    @required this.slowModeOn,
    @required this.autoModeOn,
    @required this.loopModeOn,
  }) : super(key: key);

  final MediaItem mediaItem;
  final int mediaIndex;

  final bool hideVocableModeOn;
  final bool slowModeOn;
  final bool autoModeOn;
  final bool loopModeOn;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextArea(
          hideVocableModeOn: hideVocableModeOn,
          text: mediaItem.text,
        ),
        mediaItem is VideoItem
            ? LectaryVideoPlayer(
                videoPath: mediaItem.media,
                mediaIndex: mediaIndex,
                slowMode: slowModeOn,
                autoMode: autoModeOn,
                loopMode: loopModeOn,
              )
            : (mediaItem is PictureItem
                ? ImageViewer(
                    imagePath: mediaItem.media,
                    mediaIndex: mediaIndex,
                    slowMode: slowModeOn,
                    autoMode: autoModeOn,
                    loopMode: loopModeOn,
                  )
                : TextViewer(
                    content: mediaItem.media,
                    mediaIndex: mediaIndex,
                    slowMode: slowModeOn,
                    autoMode: autoModeOn,
                    loopMode: loopModeOn,
                  ))
      ],
    );
  }
}
