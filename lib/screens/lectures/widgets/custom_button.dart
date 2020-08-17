import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final int size;
  final Color iconColor;
  final int iconContainerWidth;
  final Function func;

  CustomButton(
      {@required this.color,
      @required this.icon,
      @required this.size,
      this.iconColor = ColorsLectary.white,
      this.iconContainerWidth = 0,
      this.func = emptyFunction});

  @override
  Widget build(BuildContext context) {
    /// common button widget with style, used in the lecture screen
    return Expanded(
      child: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0))
        ),
        color: color,
        child: Container(

          /// additional container for aligning rectangular icons correctly
          width: iconContainerWidth == 0 ? size.toDouble() : iconContainerWidth
              .toDouble(),
          child: Icon(icon, size: size.toDouble(), color: iconColor),
        ),
        onPressed: func,
      ),
    );
  }

  static emptyFunction() {}
}
