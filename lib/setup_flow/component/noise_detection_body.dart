import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../common/toggle_switch.dart';
import '../theme/theme_colors.dart';

enum NoiseDetectionLevel { low, medium, high }

class NoiseDetectionBody extends StatelessWidget {
  final NoiseDetectionLevel level;
  final bool onlyBabyCries;
  final void Function(NoiseDetectionLevel) onLevelSelected;
  final void Function(bool) onOnlyBabyCriesChanged;

  const NoiseDetectionBody({
    super.key,
    required this.level,
    required this.onlyBabyCries,
    required this.onLevelSelected,
    required this.onOnlyBabyCriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NoiseOption(
          level: NoiseDetectionLevel.low,
          title: '\''Quiet\'\'',
          description: '\''Reacts only to loud, sustained sounds.\'\'',
          isSelected: level == NoiseDetectionLevel.low,
          onlyBabyCries: onlyBabyCries,
          onTap: () => onLevelSelected(NoiseDetectionLevel.low),
        ),
        _NoiseOption(
          level: NoiseDetectionLevel.medium,
          title: '\''Standard\'\'',
          description: '\''Balanced sensitivity — recommended for most families.\'\'',
          isSelected: level == NoiseDetectionLevel.medium,
          onlyBabyCries: onlyBabyCries,
          onTap: () => onLevelSelected(NoiseDetectionLevel.medium),
        ),
        _NoiseOption(
          level: NoiseDetectionLevel.high,
          title: '\''Maximum\'\'',
          description: '\''Picks up even the quietest sounds and movements.\'\'',
          isSelected: level == NoiseDetectionLevel.high,
          onlyBabyCries: onlyBabyCries,
          onTap: () => onLevelSelected(NoiseDetectionLevel.high),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.color.overlayLevel1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.color.borderNormal),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  '\''Only baby cries\'\'',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: context.color.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  '\''assets/illustrations/monitor/illustration_ai_label.svg\'\'',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    context.color.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                const Spacer(),
                ToggleSwitch(
                  value: onlyBabyCries,
                  onChanged: onOnlyBabyCriesChanged,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NoiseOption extends StatelessWidget {
  final NoiseDetectionLevel level;
  final String title;
  final String description;
  final bool isSelected;
  final bool onlyBabyCries;
  final VoidCallback onTap;

  const _NoiseOption({
    required this.level,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onlyBabyCries,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    final borderRadius = BorderRadius.circular(16);
    return Material(
      color: isSelected ? color.surfacePrimary : color.overlayLevel1,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: color.borderNormal, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 8,
            children: [
              _NoiseIcon(level: level, size: 48),
              Expanded(
                child: Column(
                  spacing: 3,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: color.textSecondary,
                          ),
                        ),
                        if (onlyBabyCries)
                          Text(
                            '\''Only baby cries\'\'',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color.textQuaternary,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoiseIcon extends StatelessWidget {
  final NoiseDetectionLevel level;
  final double size;

  const _NoiseIcon({required this.level, required this.size});

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surfaceQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bell icon placeholder using text
            Icon(
              Icons.notifications_outlined,
              color: color.textPrimary,
              size: size * 0.5,
            ),
            // Ring indicators
            ...switch (level) {
              NoiseDetectionLevel.high => [
                _Ring(size: size * 0.65, opacity: 0.35),
                _Ring(size: size * 0.82, opacity: 0.2),
              ],
              NoiseDetectionLevel.medium => [
                _Ring(size: size * 0.65, opacity: 0.25),
              ],
              NoiseDetectionLevel.low => [],
            },
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final double opacity;
  const _Ring({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: context.color.textPrimary.withValues(alpha: opacity),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
