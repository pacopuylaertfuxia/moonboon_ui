import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeColors {
  final Color brandPrimary;
  final Color brandSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textQuaternary;
  final Color textInverse;
  final Color textInactive;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  final Color surfaceQuaternary;
  final Color surfaceSubdued;
  final Color borderSubdued;
  final Color borderNormal;
  final Color borderStrong;
  final Color feedbackError;
  final Color feedbackSuccess;
  final Color feedbackInfo;
  final Color overlayLevel1;
  final Color overlayLevel2;
  final Color overlayNavButton;

  const ThemeColors({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textQuaternary,
    required this.textInverse,
    required this.textInactive,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.surfaceQuaternary,
    required this.surfaceSubdued,
    required this.borderSubdued,
    required this.borderNormal,
    required this.borderStrong,
    required this.feedbackError,
    required this.feedbackSuccess,
    required this.feedbackInfo,
    required this.overlayLevel1,
    required this.overlayLevel2,
    required this.overlayNavButton,
  });

  static const ThemeColors light = ThemeColors(
    brandPrimary: clay,
    brandSecondary: olive,
    textPrimary: black,
    textSecondary: obsadianGrey,
    textTertiary: olive,
    textQuaternary: clay,
    textInverse: white,
    textInactive: Color(0xFFCDCDCD),
    surfacePrimary: white,
    surfaceSecondary: creme,
    surfaceTertiary: mutedApricot,
    surfaceQuaternary: mutedApricot,
    surfaceSubdued: Color(0x80F5E6D3),
    borderSubdued: creme,
    borderNormal: stone,
    borderStrong: olive,
    feedbackError: errorRed,
    feedbackSuccess: successGreen,
    feedbackInfo: Color(0xFF4A6A85),
    overlayLevel1: Color(0x33FFFFFF),
    overlayLevel2: Color(0x80FFFFFF),
    overlayNavButton: Color(0xE6F1E8DE),
  );

  static const ThemeColors dark = ThemeColors(
    brandPrimary: clay,
    brandSecondary: mutedApricot,
    textPrimary: white,
    textSecondary: clay,
    textTertiary: olive,
    textQuaternary: obsadianGrey,
    textInverse: black,
    textInactive: Color(0xFF707070),
    surfacePrimary: black,
    surfaceSecondary: offBlack,
    surfaceTertiary: obsadianGrey,
    surfaceQuaternary: olive,
    surfaceSubdued: Color(0x80F5E6D3),
    borderSubdued: obsadianGrey,
    borderNormal: clay,
    borderStrong: clay,
    feedbackError: Color(0xFFEF5350),
    feedbackSuccess: liveGreen,
    feedbackInfo: Color(0xFF5B86A3),
    overlayLevel1: Color(0x33000000),
    overlayLevel2: Color(0x80000000),
    overlayNavButton: Color(0xE6292929),
  );
}

extension ThemeColorsExtension on BuildContext {
  ThemeColors get color {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? ThemeColors.dark : ThemeColors.light;
  }
}
