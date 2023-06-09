import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';

class CustomAppTheme {
  static ThemeData defaultLightTheme = _themeData(_lightColorScheme);
  static ThemeData defaultDarkTheme = _themeData(_darkColorScheme);

  static ThemeData _themeData(ColorScheme colorScheme) {
    // Using `.from` instead of default constructor, so that `scaffoldBackgroundColor` is correctly
    // initialized without using material3
    return ThemeData.from(colorScheme: colorScheme).copyWith(
      typography: Typography.material2018(platform: TargetPlatform.android),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ColorsLectary.lightBlue,
      ),
      iconTheme: IconThemeData(
        color: ColorsLectary.lightBlue,
      ),
      appBarTheme: AppBarTheme(
          foregroundColor: Colors.black,
          backgroundColor: ColorsLectary.white,
          iconTheme: IconThemeData(
            color: ColorsLectary.lightBlue,
          )),
    );
  }

  static const _lightColorScheme = ColorScheme.light(
    primary: ColorsLectary.white,
    onPrimary: Colors.black,
    secondary: ColorsLectary.lightBlue,
    onSecondary: ColorsLectary.white,
    background: ColorsLectary.white,
    onBackground: ColorsLectary.lightBlue,
    surface: ColorsLectary.white,
  );

  static const _darkColorScheme = ColorScheme.dark(
    primary: ColorsLectary.white,
    onPrimary: Colors.black,
    secondary: ColorsLectary.lightBlue,
    onSecondary: ColorsLectary.white,
    background: ColorsLectary.darkBlue,
    onBackground: ColorsLectary.white,
    surface: ColorsLectary.white,
  );

  static TextStyle hyperlink(BuildContext context) {
    return Theme.of(context).textTheme.bodyText1!.copyWith(color: ColorsLectary.red);
  }
}
