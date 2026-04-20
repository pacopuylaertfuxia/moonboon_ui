import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'theme_colors.dart';

// Builds a ThemeData for any ThemeColors variant — used by the variant switcher
ThemeData buildThemeWithColors(ThemeColors colors, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: colors.surfaceSecondary,
    colorScheme: brightness == Brightness.light
        ? ColorScheme.light(
            primary: colors.brandPrimary,
            secondary: colors.brandSecondary,
            surface: colors.surfacePrimary,
          )
        : ColorScheme.dark(
            primary: colors.brandPrimary,
            secondary: colors.brandSecondary,
            surface: colors.surfacePrimary,
          ),
    textTheme: _buildTextTheme(brightness),
    extensions: [ThemeColorsData(colors)],
    useMaterial3: true,
  );
}

ThemeData buildLightTheme() => buildThemeWithColors(ThemeColors.light, Brightness.light);
ThemeData buildDarkTheme() => buildThemeWithColors(ThemeColors.dark, Brightness.dark);

TextTheme _buildTextTheme(Brightness brightness) {
  final textColor = brightness == Brightness.dark ? white : black;

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
      color: textColor,
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
