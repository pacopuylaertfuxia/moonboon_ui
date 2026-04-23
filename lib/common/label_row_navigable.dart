import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/theme_colors.dart';
import 'label_row.dart';

class LabelRowNavigable extends StatelessWidget {
  final String? iconPath;
  final String label;
  final VoidCallback? onTap;
  final Color? labelColor;

  const LabelRowNavigable({
    super.key,
    this.iconPath,
    required this.label,
    this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return InkWell(
      splashColor: c.surfaceSecondary,
      highlightColor: c.surfaceSecondary.withValues(alpha: 0.5),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: LabelRow(
        iconPath: iconPath,
        label: label,
        labelColor: labelColor,
        trailing: SvgPicture.asset(
          'assets/icons/utility/chevron_right.svg',
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(c.surfaceTertiary, BlendMode.srcIn),
        ),
      ),
    );
  }
}
