import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

class SurfaceCard extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget child;

  const SurfaceCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: context.color.surfacePrimary,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
