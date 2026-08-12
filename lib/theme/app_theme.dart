import 'package:flutter/material.dart';
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
            surface: colors.surfaceSecondary,
            onPrimary: colors.textInverse,
            onSecondary: colors.textInverse,
            onSurface: colors.textPrimary,
          )
        : ColorScheme.dark(
            primary: colors.brandPrimary,
            secondary: colors.brandSecondary,
            surface: colors.surfaceSecondary,
            onPrimary: colors.textInverse,
            onSecondary: colors.textInverse,
            onSurface: colors.textPrimary,
          ),
    textTheme: _buildTextTheme(colors),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'KeplerStd',
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.0,
      ),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.textQuaternary; // clay
        }
        return const Color(0x33787878); // grey 20% — fillsPrimary
      }),
      thumbIcon: WidgetStateProperty.all(
        const Icon(Icons.check, color: Colors.white),
      ),
    ),
    iconTheme: IconThemeData(color: colors.brandSecondary),
    extensions: [ThemeColorsData(colors)],
    useMaterial3: true,
  );
}

ThemeData buildLightTheme() =>
    buildThemeWithColors(ThemeColors.light, Brightness.light);
ThemeData buildDarkTheme() =>
    buildThemeWithColors(ThemeColors.darkVariantC, Brightness.dark);

TextTheme _buildTextTheme(ThemeColors colors) {
  return TextTheme(
    // Display / Headline — KeplerStd, textPrimary
    headlineLarge: TextStyle(
      fontFamily: 'KeplerStd',
      fontSize: 38,
      fontWeight: FontWeight.w400,
      color: colors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'KeplerStd',
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: colors.textPrimary,
      height: 1.0,
    ),
    // Title — system font, textPrimary
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: colors.textPrimary,
    ),
    // Body — system font, textSecondary
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: colors.textSecondary,
      height: 1.55,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: colors.textSecondary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: colors.textSecondary,
      height: 1.5,
    ),
    // Label — system font, textSecondary
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: colors.textSecondary,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: colors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: colors.textSecondary,
    ),
  );
}
