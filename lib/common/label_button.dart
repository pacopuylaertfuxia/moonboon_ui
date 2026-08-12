import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

enum LabelButtonVariant { standard, dangerous }

class LabelButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final LabelButtonVariant variant;
  final bool isLoading;

  const LabelButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = LabelButtonVariant.standard,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final bg = variant == LabelButtonVariant.dangerous ? c.feedbackError : c.surfaceTertiary;
    final fg = variant == LabelButtonVariant.dangerous ? c.textInverse : c.textPrimary;
    const borderRadius = BorderRadius.all(Radius.circular(100));

    return Opacity(
      opacity: onTap == null ? 0.5 : 1.0,
      child: Material(
        borderRadius: borderRadius,
        color: bg,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
            ),
          ),
        ),
      ),
    );
  }
}
