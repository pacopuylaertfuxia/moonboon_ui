import 'package:flutter/material.dart';

class CircularLoadingBar extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const CircularLoadingBar({
    super.key,
    this.size = 24,
    this.color = Colors.grey,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeCap: StrokeCap.round,
      color: color,
      strokeWidth: strokeWidth,
      constraints: BoxConstraints.tightFor(width: size, height: size),
    );
  }
}
