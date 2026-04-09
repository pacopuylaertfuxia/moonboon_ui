import 'package:flutter/material.dart';

const Color clay = Color(0xFFB59E85);
const Color olive = Color(0xFF70695F);
const Color obsadianGrey = Color(0xFF464545);
const Color creme = Color(0xFFF1E8DE);
const Color mutedApricot = Color(0xFFE5D5C5);
const Color stone = Color(0xFFDDD6CC);
const Color offWhite = Color(0xFFF5F3F1);
const Color offBlack = Color(0xFF292929);
const Color white = Color(0xFFFFFEFD);
const Color black = Color(0xFF010101);
const Color liveGreen = Color(0xFF66BB6A);
const Color errorRed = Color(0xFFB94A48);
const Color successGreen = Color(0xFF5E8A66);

const Color primaryColor = olive;
const Color secondaryColor = clay;

Color textColor(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.dark ? creme : olive;
}
