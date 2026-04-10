import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/button.dart';
import '../../common/toggle_switch.dart';
import '../../theme/theme_colors.dart';

enum NoiseDetectionLevel { low, medium, high }

class NoiseDetectionBody extends StatelessWidget {
  final NoiseDetectionLevel level;
  final bool onlyBabyCries;
  final void Function(NoiseDetectionLevel) onLevelSelected;
  final void Function(bool) onOnlyBabyCriesChanged;
  final VoidCallback onContinue;

  const NoiseDetectionBody({
    super.key,
    required this.level,
    required this.onlyBabyCries,
    required this.onLevelSelected,
    required this.onOnlyBabyCriesChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final bottomPadding = MediaQuery.of(context).padding.bottom > 0
        ? MediaQuery.of(context).padding.bottom + 8
        : 16.0;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 44, 16, bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "You're all set for\nsound alerts",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              "Here's what we've enabled for you to start with. You can adjust it anytime.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: c.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            // Modes
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModeRow(
                  level: NoiseDetectionLevel.low,
                  title: 'Quiet mode',
                  description: 'Alerts you after loud consistent sounds',
                  isSelected: level == NoiseDetectionLevel.low,
                  onTap: () => onLevelSelected(NoiseDetectionLevel.low),
                ),
                _ModeRow(
                  level: NoiseDetectionLevel.medium,
                  title: 'Standard mode',
                  description: 'Alerts you after mild noticeable sounds',
                  isSelected: level == NoiseDetectionLevel.medium,
                  onTap: () => onLevelSelected(NoiseDetectionLevel.medium),
                ),
                _ModeRow(
                  level: NoiseDetectionLevel.high,
                  title: 'Maximum mode',
                  description: 'Alerts you as soon as a sound is detected',
                  isSelected: level == NoiseDetectionLevel.high,
                  onTap: () => onLevelSelected(NoiseDetectionLevel.high),
                ),
                // Only baby cries toggle
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.borderNormal),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Only baby cries',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/illustrations/monitor/illustration_ai_label.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            c.textSecondary,
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
                // Continue button
                Button(
                  onPressed: onContinue,
                  buttonLabel: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  variant: ButtonVariant.primary,
                  size: ButtonSize.lg,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  final NoiseDetectionLevel level;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeRow({
    required this.level,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final borderRadius = BorderRadius.circular(16);
    return Material(
      color: isSelected ? c.surfacePrimary : c.overlayLevel1,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: c.borderNormal,
          width: isSelected ? 2 : 1,
        ),
      ),
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.05),
      elevation: isSelected ? 2 : 0,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected ? c.textPrimary : c.textSecondary,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.textTertiary,
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
    final c = context.color;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceQuaternary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...switch (level) {
              NoiseDetectionLevel.high => [
                _Ring(size: size * 0.65, color: c.textPrimary, opacity: 0.35),
                _Ring(size: size * 0.82, color: c.textPrimary, opacity: 0.2),
              ],
              NoiseDetectionLevel.medium => [
                _Ring(size: size * 0.65, color: c.textPrimary, opacity: 0.25),
              ],
              NoiseDetectionLevel.low => [],
            },
            Icon(
              Icons.notifications_outlined,
              color: c.textPrimary,
              size: size * 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Ring({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
