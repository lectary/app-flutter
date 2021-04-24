import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:lectary/screens/lectures/widgets/custom_button.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/icons.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


/// A [Row] of custom button widgets for controlling the different modes of the media
/// items in the carousel like slowMode, autoStart and autoReplay.
/// Sets and listens for changes of the modes in the [CarouselViewModel].
class MediaControlArea extends StatefulWidget {
  final int flex;

  MediaControlArea({required this.flex});

  @override
  _MediaControlAreaState createState() => _MediaControlAreaState();
}

class _MediaControlAreaState extends State<MediaControlArea> {

  @override
  Widget build(BuildContext context) {
    log("build media-control-area");
    final bool slowModeOn = context.select((CarouselViewModel model) => model.slowModeOn);
    final bool autoModeOn = context.select((CarouselViewModel model) => model.autoModeOn);
    final bool loopModeOn = context.select((CarouselViewModel model) => model.loopModeOn);
    // Increase icon size on tablets
    final mediaWidth = MediaQuery.of(context).size.width;
    double iconSize = mediaWidth >= Constants.breakpointTablet ? 50 : 35;
    double iconContainerWidth = mediaWidth >= Constants.breakpointTablet ? 160 : 80;
    return Expanded(
      flex: widget.flex,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomButton(
            color: slowModeOn ? ColorsLectary.yellow : ColorsLectary.darkBlue,
            // custom icon from the asset icon-fonts
            iconData: LectaryIcons.iconTurtle,
            semanticLabel: Constants.semanticSlowMode,
            iconSize: iconSize,
            func: () => Provider.of<CarouselViewModel>(context, listen: false)
                .slowModeOn = slowModeOn ? false : true,
          ),
          CustomButton(
            color: autoModeOn ? ColorsLectary.orange : ColorsLectary.darkBlue,
            iconData: LectaryIcons.iconWordAuto,
            semanticLabel: Constants.semanticAutoMode,
            iconSize: iconSize,
            iconContainerWidth: iconContainerWidth,
            func: () =>
            Provider.of<CarouselViewModel>(context, listen: false)
                .autoModeOn = autoModeOn ? false : true,
          ),
          CustomButton(
            color: loopModeOn ? ColorsLectary.red : ColorsLectary.darkBlue,
            iconData: LectaryIcons.iconReload,
            semanticLabel: Constants.semanticReplayMode,
            iconSize: iconSize,
            func: () =>
            Provider.of<CarouselViewModel>(context, listen: false)
                .loopModeOn = loopModeOn ? false : true,
          )
        ],
      ),
    );
  }
}
