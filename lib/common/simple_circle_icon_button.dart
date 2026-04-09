import 'package:flutter/material.dart';

class SimpleCircleIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color color;

  const SimpleCircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.width = 44,
    this.height = 44,
    this.color = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: icon),
      ),
    );
  }
}
