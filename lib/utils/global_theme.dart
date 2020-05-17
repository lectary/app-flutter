import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';

ThemeData LectaryTheme() {
 return ThemeData(
   typography: Typography.material2018(platform: TargetPlatform.android),
   // This makes the visual density adapt to the platform that you run
   // the app on. For desktop platforms, the controls will be smaller and
   // closer together (more dense) than on mobile platforms.
   visualDensity: VisualDensity.adaptivePlatformDensity,
 );
}