import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';


/// Customized button widget with a special style, used several times
/// in the lecture screen
class CustomButton extends StatelessWidget {
  final Color color;
  final IconData iconData;
  final String semanticLabel;
  final double iconSize;
  final Color iconColor;
  final double iconContainerWidth;
  final Function func;

  CustomButton(
      {@required this.color,
      @required this.iconData,
      @required this.semanticLabel,
      @required this.iconSize,
      this.iconColor = ColorsLectary.white,
      this.iconContainerWidth = 0,
      this.func = emptyFunction});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))),
        color: color,
        child: Container(
          /// additional container for aligning rectangular icons correctly
          width: iconContainerWidth == 0 ? iconSize : iconContainerWidth,
          child: Icon(iconData,
              size: iconSize, color: iconColor, semanticLabel: semanticLabel),
        ),
        onPressed: func,
      ),
    );
  }

  static emptyFunction() {}
}
