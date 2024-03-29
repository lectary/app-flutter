import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/carousel.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';

/// Overlay with two buttons for navigating the [Carousel]
/// Can be disabled via the settings
class CarouselNavigationOverlay extends StatelessWidget {
  final CarouselController carouselController;

  final widthFactorOfNavigationArrows = 0.5;

  const CarouselNavigationOverlay({super.key, required this.carouselController});

  @override
  Widget build(BuildContext context) {
    bool isOverlayOn = context.select((SettingViewModel model) => model.settingShowMediaOverlay);
    // Increase icon size on tablets
    final mediaWidth = MediaQuery.of(context).size.width;
    double navigationIconSize = mediaWidth >= Constants.breakpointTablet ? 90 : 60;
    return ExcludeSemantics(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        ClipRect(
          child: Align(
            widthFactor: widthFactorOfNavigationArrows,
            alignment: Alignment.center,
            child: Opacity(
              opacity: isOverlayOn ? Constants.opacityOfCarouselOverLay : 0,
              child: Column(
                // Column combined with expanded to stretch the iconButton vertically
                children: [
                  Expanded(
                    child: IconButton(
                      padding: const EdgeInsets.all(0.0),
                      iconSize: navigationIconSize,
                      icon: const Icon(
                        Icons.keyboard_arrow_left,
                        color: ColorsLectary.white,
                      ),
                      onPressed: () => carouselController.previousPage(
                          duration: const Duration(milliseconds: 300), curve: Curves.linear),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ClipRect(
          child: Align(
            widthFactor: widthFactorOfNavigationArrows,
            alignment: Alignment.center,
            child: Opacity(
              opacity: isOverlayOn ? Constants.opacityOfCarouselOverLay : 0,
              child: Column(
                children: [
                  Expanded(
                    child: IconButton(
                      padding: const EdgeInsets.all(0.0),
                      iconSize: navigationIconSize,
                      icon: const Icon(
                        Icons.keyboard_arrow_right,
                        color: ColorsLectary.white,
                      ),
                      onPressed: () => carouselController.nextPage(
                          duration: const Duration(milliseconds: 300), curve: Curves.linear),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}
