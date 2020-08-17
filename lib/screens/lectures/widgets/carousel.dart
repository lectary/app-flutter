import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer.dart';


class Carousel extends StatefulWidget {
  final List<Vocable> vocables;
  final CarouselController carouselController;

  Carousel({this.vocables, this.carouselController, Key key}) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {

  @override
  void initState() {
    super.initState();
    /// Adding callback for jumping to the selected [Vocable] after the [Carousel] is initialized fully and
    /// the [widget.carouselController] is set properly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = Provider.of<CarouselViewModel>(context, listen: false)
          .currentItemIndex;
      if (index != 0) widget.carouselController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    log("build carousel");
    final double height = MediaQuery.of(context).size.height;

    return CarouselSlider.builder(
        carouselController: widget.carouselController,
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
        itemCount: widget.vocables.length,
        itemBuilder: (BuildContext context, int itemIndex) =>
            MediaViewer(vocable: widget.vocables[itemIndex], vocableIndex: itemIndex));
  }
}
