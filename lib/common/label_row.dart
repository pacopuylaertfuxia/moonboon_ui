import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/theme_colors.dart';

class LabelRow extends StatelessWidget {
  final String? iconPath;
  final String label;
  final Widget trailing;
  final EdgeInsets? padding;
  final Color? labelColor;

  const LabelRow({
    super.key,
    this.padding,
    this.iconPath,
    required this.label,
    required this.trailing,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final children = <Widget>[
      Expanded(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: labelColor ?? c.textSecondary),
        ),
      ),
      trailing,
    ];

    if (iconPath != null) {
      children.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SvgPicture.asset(
            iconPath!,
            height: 18,
            width: 18,
            colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      child: Row(spacing: 8, children: children),
    );
  }
}
