import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer_image.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer_text.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer_text_area.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer_video.dart';


/// Class responsible for displaying the correct media player corresponding to the
/// [MediaType] of the [Vocable].
/// Uses either [LectaryVideoPlayer], [ImageViewer] or [TextViewer].
/// For the vocable itself, it uses [TextArea].
/// Listens on [CarouselViewModel] for changes regarding media-modes and vocable visibility.
class MediaViewer extends StatelessWidget {
  const MediaViewer({
    Key key,
    @required this.vocable,
    @required this.vocableIndex
  }) : super(key: key);

  final Vocable vocable;
  final int vocableIndex;

  @override
  Widget build(BuildContext context) {
    log("build media-viewer with index: $vocableIndex");
    final bool hideVocableModeOn = context.select((CarouselViewModel model) => model.hideVocableModeOn);
    final bool slowModeOn = context.select((CarouselViewModel model) => model.slowModeOn);
    final bool autoModeOn = context.select((CarouselViewModel model) => model.autoModeOn);
    final bool loopModeOn = context.select((CarouselViewModel model) => model.loopModeOn);

    final bool isVirtualLecture = context.select((CarouselViewModel model) => model.isVirtualLecture);
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    // TODO fix case OrElse
    String lectureName = model.localLectures.firstWhere((lecture) => lecture.id == vocable.lectureId).lesson;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextArea(
          hideVocableModeOn: hideVocableModeOn,
          text: isVirtualLecture ? vocable.vocable + "\n[$lectureName]"
          : vocable.vocable,
        ),
        () {
        // assert that all mediaTypes are valid, otherwise would be filtered before by the models
          switch (MediaType.fromString(vocable.mediaType)) {
            case MediaType.MP4:
              return LectaryVideoPlayer(
                videoPath: vocable.media,
                mediaIndex: vocableIndex,
                slowMode: slowModeOn,
                autoMode: autoModeOn,
                loopMode: loopModeOn,
                audio: vocable.audio,
              );
            case MediaType.PNG:
            case MediaType.JPG:
              return ImageViewer(
                imagePath: vocable.media,
                mediaIndex: vocableIndex,
                slowMode: slowModeOn,
                autoMode: autoModeOn,
              );
            case MediaType.TXT:
              return TextViewer(
                content: vocable.media,
                mediaIndex: vocableIndex,
                slowMode: slowModeOn,
                autoMode: autoModeOn,
              );
          }
        } ()
      ],
    );
  }
}
