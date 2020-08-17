import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer.dart';


class Carousel extends StatelessWidget {

  final List<Vocable> vocables;
  final CarouselController carouselController;

  Carousel({this.vocables, this.carouselController, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("build carousel");
    final double height = MediaQuery.of(context).size.height;

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
              Provider.of<CarouselViewModel>(context, listen: false)
                  .currentItemIndex = index;
            }),
        itemCount: vocables.length,
        itemBuilder: (BuildContext context, int itemIndex) =>
            MediaViewer(vocable: vocables[itemIndex], vocableIndex: itemIndex));
  }
}
