import 'dart:ui';

import 'package:flutter/material.dart';

/// Color.class needs Integer values
/// #FFDA5D (yellow) converts to 0xFFDA5D
/// Opacity has to be considered and added with two leading hex-values (0x00-0xFF)
/// Therefore, the final yellow value with full opacity is 0xFFFFDA5D
class ColorsLectary {
  static const white = const Color(0xFFF8F8F8);
  static const yellow = const Color(0xFFFFDA5D);
  static const orange = const Color(0xFFF48E5B);
  static const red = const Color(0xFFE95876);
  static const green = const Color(0xFF97E975);
  static const lightblue = const Color(0xFF5AC1CF);
  static const darkblue = const Color(0xFF053751);
  static const violett = const Color(0xFFB65DFF);
}