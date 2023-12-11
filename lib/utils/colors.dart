import 'package:flutter/material.dart';

/// Color.class needs Integer values
/// #FFDA5D (yellow) converts to 0xFFDA5D
/// Opacity has to be considered and added with two leading hex-values (0x00-0xFF)
/// Therefore, the final yellow value with full opacity is 0xFFFFDA5D
class ColorsLectary {
  static const white = Color(0xFFF8F8F8);
  static const yellow = Color(0xFFFFDA5D);
  static const orange = Color(0xFFF48E5B);
  static const red = Color(0xFFE95876);
  static const green = Color(0xFF97E975);
  static const lightBlue = Color(0xFF5AC1CF);
  static const darkBlue = Color(0xFF053751);
  static const violet = Color(0xFFB65DFF);

  static const logoDarkBlue = Color.fromRGBO(7, 54, 80, 1);

  static const MaterialColor whiteSwatch = MaterialColor(0xFFF8F8F8, whiteCodes);
}

const Map<int, Color> whiteCodes = {
  50: Color.fromRGBO(248, 248, 248, .1),
  100: Color.fromRGBO(248, 248, 248, .2),
  200: Color.fromRGBO(248, 248, 248, .3),
  300: Color.fromRGBO(248, 248, 248, .4),
  400: Color.fromRGBO(248, 248, 248, .5),
  500: Color.fromRGBO(248, 248, 248, .6),
  600: Color.fromRGBO(248, 248, 248, .7),
  700: Color.fromRGBO(248, 248, 248, .8),
  800: Color.fromRGBO(248, 248, 248, .9),
  900: Color.fromRGBO(248, 248, 248, 1),
};
