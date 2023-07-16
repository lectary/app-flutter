import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';

class CustomAppTheme {
  static ThemeData defaultLightTheme = _themeData(_lightColorScheme);
  static ThemeData defaultDarkTheme = _themeData(_darkColorScheme);

  static ThemeData _themeData(ColorScheme colorScheme) {
    // Using `.from` instead of default constructor, so that `scaffoldBackgroundColor` is correctly
    // initialized without using material3
    final baseTheme = ThemeData.from(colorScheme: colorScheme);
    return baseTheme.copyWith(
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
        /// Tricky one here:
        /// If left out, the style will be taken from [TextTheme.titleLarge], however, this is customized later.
        /// It is NOT possible to use [baseTheme.textTheme.titleLarge] (default one before its customized),
        /// since this does not contain any geometry values, yet!
        /// Therefore, all values needs to be set explicitly here.
        /// See [https://github.com/flutter/flutter/issues/86709].
        /// Values are the defaults from [Typography.englishLike2018]
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w500),
        iconTheme: IconThemeData(
          color: ColorsLectary.lightBlue,
        ),
      ),
      textTheme: colorScheme.brightness == Brightness.light
          ? _lightTextTheme(baseTheme)
          : _darkTextTheme(baseTheme),
    );
  }

  static TextTheme _lightTextTheme(ThemeData baseTheme) {
    return baseTheme.textTheme.copyWith(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: ColorsLectary.lightBlue),
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: ColorsLectary.lightBlue),
      bodySmall: TextStyle(color: ColorsLectary.lightBlue),
    );
  }

  static TextTheme _darkTextTheme(ThemeData baseTheme) {
    return baseTheme.textTheme.copyWith(
      titleLarge: TextStyle(color: ColorsLectary.white),
      titleMedium: TextStyle(color: ColorsLectary.white),
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

  // CUSTOM TEXT STYLES

  static TextStyle hyperlink(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(color: ColorsLectary.red);
  }
}
