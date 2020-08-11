import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';


ThemeData lectaryThemeLight() {
  final ThemeData base = ThemeData(primarySwatch: ColorsLectary.whiteSwatch);
  return base.copyWith(
    typography: Typography.material2018(platform: TargetPlatform.android),
    visualDensity: VisualDensity.adaptivePlatformDensity,

    primaryColor: ColorsLectary.white,
    brightness: Brightness.light,
    accentColor: ColorsLectary.lightBlue,

    toggleableActiveColor: ColorsLectary.lightBlue,

    primaryIconTheme: base.primaryIconTheme.copyWith(color: ColorsLectary.lightBlue),
    iconTheme: base.iconTheme.copyWith(color: ColorsLectary.lightBlue),

    textTheme: base.textTheme.copyWith(caption: TextStyle(color: ColorsLectary.lightBlue)),
  );
}


ThemeData lectaryThemeDark() {
  final ThemeData base = lectaryThemeLight();
  return base.copyWith(
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: ColorsLectary.lightBlue,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ColorsLectary.darkBlue,

      textTheme: base.textTheme.copyWith(headline6: TextStyle(color: ColorsLectary.white), subtitle1: TextStyle(color: ColorsLectary.white)),
  );
}