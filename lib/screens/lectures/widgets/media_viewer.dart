import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
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
    @required this.vocableIndex,
  }) : super(key: key);

  final Vocable vocable;
  final int vocableIndex;

  /// Retrieve the lecture name of the vocable in case of a virtual-lecture.
  /// Returns the [Lecture.lesson] of the current [vocable].
  String _getLectureName(BuildContext context) {
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    String lectureName = "";
    if (model.localLectures != null) {
      Lecture lecture = model.localLectures.firstWhere(
              (lecture) => lecture.id == vocable.lectureId,
          orElse: () => null);
      lectureName = lecture == null ? "" : lecture.lesson;
    }
    return lectureName;
  }

  @override
  Widget build(BuildContext context) {
    log("build media-viewer with index: $vocableIndex");
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Builder(
          builder: (BuildContext context) {
            final bool hideVocableModeOn = context.select((CarouselViewModel model) => model.hideVocableModeOn);
            final bool isVirtualLecture = context.select((CarouselViewModel model) => model.isVirtualLecture);
            return TextArea(
              key: UniqueKey(),
              hideVocableModeOn: hideVocableModeOn,
              mediaIndex: vocableIndex,
              text: isVirtualLecture
                  ? vocable.vocable + "\n[${_getLectureName(context)}]"
                  : vocable.vocable,
            );
          },
        ),
        Builder(
          builder: (BuildContext context) {
            final bool slowModeOn = context.select((CarouselViewModel model) => model.slowModeOn);
            final bool autoModeOn = context.select((CarouselViewModel model) => model.autoModeOn);
            final bool loopModeOn = context.select((CarouselViewModel model) => model.loopModeOn);

            Widget resultWidget;
            switch (MediaType.fromString(vocable.mediaType)) {
              case MediaType.MP4:
                resultWidget = LectaryVideoPlayer(
                  videoPath: vocable.media,
                  mediaIndex: vocableIndex,
                  slowMode: slowModeOn,
                  autoMode: autoModeOn,
                  loopMode: loopModeOn,
                  audio: vocable.audio,
                );
                break;
              case MediaType.PNG:
              case MediaType.JPG:
                resultWidget = ImageViewer(
                  imagePath: vocable.media,
                  mediaIndex: vocableIndex,
                  slowMode: slowModeOn,
                  autoMode: autoModeOn,
                );
                break;
              case MediaType.TXT:
                resultWidget = TextViewer(
                  content: vocable.media,
                  mediaIndex: vocableIndex,
                  slowMode: slowModeOn,
                  autoMode: autoModeOn,
                );
                break;
              default:
                // Should be unreachable
                // assert that all mediaTypes are valid, otherwise the vocable should had been filtered beforehand
                resultWidget = Container();
                break;
            }
            return resultWidget;
          },
        ),
      ],
    );
  }
}
