import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/theme_colors.dart';

enum ActionListTileTrailingType { chevron, none, custom, toggle, radio }

enum ActionListTileVariant { list, grid, clean }

class ActionListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leadingIcon;
  final String? leadingIconAsset;
  final ActionListTileTrailingType trailingType;
  final Widget? customTrailingIcon;
  final VoidCallback? onTap;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final Color? backgroundColor;
  final bool isPrimary;
  final ActionListTileVariant variant;

  const ActionListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingIconAsset,
    this.trailingType = ActionListTileTrailingType.chevron,
    this.customTrailingIcon,
    this.onTap,
    this.toggleValue,
    this.onToggleChanged,
    this.backgroundColor,
    this.isPrimary = false,
    this.variant = ActionListTileVariant.list,
  });

  Widget? _buildTrailingIcon(BuildContext context) {
    switch (trailingType) {
      case ActionListTileTrailingType.chevron:
        return SvgPicture.asset(
          'assets/icons/utility/chevron_right.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(context.color.textTertiary, BlendMode.srcIn),
        );
      case ActionListTileTrailingType.custom:
        return customTrailingIcon;
      case ActionListTileTrailingType.toggle:
        return SizedBox(
          width: 48,
          height: 24,
          child: Switch.adaptive(
            value: toggleValue ?? false,
            onChanged: onToggleChanged,
          ),
        );
      case ActionListTileTrailingType.none:
        return null;
      case ActionListTileTrailingType.radio:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final trailingIcon = _buildTrailingIcon(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? c.overlayBrand,
          borderRadius: BorderRadius.circular(8),
        ),
        child: variant == ActionListTileVariant.grid
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leadingIcon != null) leadingIcon!,
                    if (leadingIconAsset != null)
                      SvgPicture.asset(
                        leadingIconAsset!,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(c.brandPrimary, BlendMode.srcIn),
                      ),
                    const Spacer(),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: c.textPrimary,
                            height: 1,
                          ),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 16)],
                    if (leadingIconAsset != null) ...[
                      SvgPicture.asset(
                        leadingIconAsset!,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(c.brandPrimary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailingIcon != null) ...[const SizedBox(width: 16), trailingIcon],
                  ],
                ),
              ),
      ),
    );
  }
}
