import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:lectary/screens/lectures/widgets/custom_button.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';


class MediaControlArea extends StatefulWidget {
  final int flex;

  MediaControlArea({this.flex});

  @override
  _MediaControlAreaState createState() => _MediaControlAreaState();
}

class _MediaControlAreaState extends State<MediaControlArea> {
  Widget build(BuildContext context) {
    log("build media-control-area");
    final bool slowModeOn = context.select((CarouselViewModel model) => model.slowModeOn);
    final bool autoModeOn = context.select((CarouselViewModel model) => model.autoModeOn);
    final bool loopModeOn = context.select((CarouselViewModel model) => model.loopModeOn);

    return Expanded(
      flex: widget.flex,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomButton(
            color: slowModeOn ? ColorsLectary.yellow : ColorsLectary.darkBlue,
            icon: IconData(0xe900, fontFamily: 'icomoon'),
            size: 35,
            func: () =>
            Provider.of<CarouselViewModel>(context, listen: false)
                .slowModeOn = slowModeOn ? false : true,
          ),
          CustomButton(
            color: autoModeOn ? ColorsLectary.orange : ColorsLectary.darkBlue,
            icon: IconData(0xe901, fontFamily: 'icomoon'),
            size: 35,
            iconContainerWidth: 80,
            func: () =>
            Provider.of<CarouselViewModel>(context, listen: false)
                .autoModeOn = autoModeOn ? false : true,
          ),
          CustomButton(
            color: loopModeOn ? ColorsLectary.red : ColorsLectary.darkBlue,
            icon: IconData(0xe902, fontFamily: 'icomoon'),
            size: 35,
            func: () =>
            Provider.of<CarouselViewModel>(context, listen: false)
                .loopModeOn = loopModeOn ? false : true,
          )
        ],
      ),
    );
  }
}
