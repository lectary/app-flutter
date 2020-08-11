import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lectary/models/media_item.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';

import 'media_viewer.dart';

class Carousel extends StatelessWidget {

  final List<MediaItem> items;
  final CarouselController carouselController;
  final bool slowModeOn;
  final bool autoModeOn;
  final bool loopModeOn;
  final bool hideVocableModeOn;

  Carousel({this.items, this.carouselController, this.slowModeOn,
    this.autoModeOn, this.loopModeOn, this.hideVocableModeOn, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final List<MediaItem> items = Provider.of<CarouselViewModel>(context, listen: false).currentMediaItems;

    return CarouselSlider.builder(
      carouselController: carouselController,
      options: CarouselOptions(
          height: (height / 10) * 7,
          viewportFraction: 0.999999,
          // FIXME dirty hack to achieve pre-loading of previous/next page
          autoPlay: false,
          enlargeCenterPage: true,
          initialPage: 0,
          onPageChanged: (int index, CarouselPageChangedReason reason) {
            Provider.of<CarouselViewModel>(context, listen: false).currentItemIndex = index;
          }),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int itemIndex) =>

      /// media viewer - types: video, image, text
      MediaViewer(
          mediaItem: items[itemIndex],
          mediaIndex: itemIndex,
          hideVocableModeOn: hideVocableModeOn,
          slowModeOn: slowModeOn,
          autoModeOn: autoModeOn,
          loopModeOn: loopModeOn),
    );
  }
}
