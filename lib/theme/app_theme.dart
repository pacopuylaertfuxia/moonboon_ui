import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: offWhite,
    colorScheme: const ColorScheme.light(
      primary: clay,
      secondary: olive,
      surface: white,
    ),
    textTheme: _buildTextTheme(Brightness.light),
    useMaterial3: true,
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    colorScheme: const ColorScheme.dark(
      primary: clay,
      secondary: mutedApricot,
      surface: black,
    ),
    textTheme: _buildTextTheme(Brightness.dark),
    useMaterial3: true,
  );
}

TextTheme _buildTextTheme(Brightness brightness) {
  final textColor = brightness == Brightness.dark ? white : black;
  final secondaryText = brightness == Brightness.dark ? clay : obsadianGrey;

  return TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'KeplerStd',
      fontSize: 38,
      fontWeight: FontWeight.w400,
      color: textColor,
      letterSpacing: -0.5,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'KeplerStd',
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: secondaryText,
      height: 1.0,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textColor,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: textColor,
      height: 1.55,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textColor,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textColor,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
  );
}
