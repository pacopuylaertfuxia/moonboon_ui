import 'package:flutter/material.dart';

/// Fades content at edges using a gradient mask — used on scrollable lists.
class WrapFade extends StatelessWidget {
  final Widget child;
  final Color color;
  final double fadeHeight;

  const WrapFade({
    super.key,
    required this.child,
    required this.color,
    this.fadeHeight = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            Colors.transparent,
            Colors.transparent,
            color,
          ],
          stops: [
            0.0,
            fadeHeight / rect.height,
            1.0 - fadeHeight / rect.height,
            1.0,
          ],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstOut,
      child: child,
    );
  }
}
