import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:lectary/screens/lectures/widgets/media_viewer.dart';


/// Carousel widget responsible for navigating and displaying the [List] of
/// [Vocable] and playing its media contents like video, image or text.
/// Uses the package [CarouselSlider].
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final index = Provider.of<CarouselViewModel>(context, listen: false).currentItemIndex;
      if (index != 0) widget.carouselController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    log("build carousel");
    final double height = MediaQuery.of(context).size.height;
    // get initial value from viewModel for usage at app-start; reset back to 0 afterwards.
    final model = Provider.of<CarouselViewModel>(context, listen: false);
    final initialValue = model.initialCarouselValue;
    if (initialValue != 0) model.initialCarouselValue = 0;

    return CarouselSlider.builder(
        carouselController: widget.carouselController,
        options: CarouselOptions(
            height: (height / 10) * 7,
            // with this value the page before and after is visible, although not
            // perceptible, which results to a kind of pre-loading
            viewportFraction: 0.999999,
            autoPlay: false,
            enlargeCenterPage: true,
            initialPage: initialValue,
            onPageChanged: (int index, CarouselPageChangedReason reason) {
              Provider.of<CarouselViewModel>(context, listen: false).currentItemIndex = index;
            }),
        itemCount: widget.vocables.length,
        itemBuilder: (BuildContext context, int itemIndex) =>
            MediaViewer(vocable: widget.vocables[itemIndex], vocableIndex: itemIndex));
  }
}
