import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/carousel.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';


/// Overlay with two buttons for navigating the [Carousel]
/// Can be disabled via the settings
class CarouselNavigationOverlay extends StatelessWidget {
  final CarouselController carouselController;

  CarouselNavigationOverlay({this.carouselController});

  @override
  Widget build(BuildContext context) {
    bool isOverlayOn = context.select((SettingViewModel model) => model.settingShowMediaOverlay);
    return Visibility(
      visible: isOverlayOn,
      child: Stack(children: [
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
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: ColorsLectary.white,
                  ),
                  onPressed: () => carouselController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear),
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
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    color: ColorsLectary.white,
                  ),
                  onPressed: () => carouselController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear),
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}