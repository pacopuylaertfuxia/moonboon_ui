import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

class CircularLoadingBar extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const CircularLoadingBar({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeCap: StrokeCap.round,
      color: color ?? context.color.brandPrimary,
      strokeWidth: strokeWidth,
      constraints: BoxConstraints.tightFor(width: size, height: size),
    );
  }
}
