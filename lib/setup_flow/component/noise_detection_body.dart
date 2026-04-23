import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/button.dart';
import '../../common/toggle_switch.dart';
import '../../theme/theme_colors.dart';

enum NoiseDetectionLevel { low, medium, high }

/// Floating pill rendered **above** the bottom sheet to toggle between
/// the "no header" and "with header" variant of [ModeSelectionBody].
class ModeSelectionVariantToggle extends StatelessWidget {
  final bool showHeader;
  final ValueChanged<bool> onChanged;

  const ModeSelectionVariantToggle({
    super.key,
    required this.showHeader,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SegmentedControl(
      options: const ['No header', 'With header'],
      selectedIndex: showHeader ? 1 : 0,
      onChanged: (i) => onChanged(i == 1),
    );
  }
}

// Renamed: ModeSelectionBody
class ModeSelectionBody extends StatelessWidget {
  final NoiseDetectionLevel level;
  final bool onlyBabyCries;
  final void Function(NoiseDetectionLevel) onLevelSelected;
  final void Function(bool) onOnlyBabyCriesChanged;
  final VoidCallback onContinue;
  final String? title;
  final String? subtitle;
  final String continueLabel;

  const ModeSelectionBody({
    super.key,
    required this.level,
    required this.onlyBabyCries,
    required this.onLevelSelected,
    required this.onOnlyBabyCriesChanged,
    required this.onContinue,
    this.title,
    this.subtitle,
    this.continueLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final buttonBottom = safeBottom > 0 ? safeBottom + 8 : 48.0;
    final showHeader = title != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHeader) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    subtitle ?? 'Choose how sensitive the monitor should be to sounds.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModeRow(
                    level: NoiseDetectionLevel.low,
                    title: 'Quiet',
                    description: 'Alerts you after loud consistent sounds',
                    isSelected: level == NoiseDetectionLevel.low,
                    onlyBabyCries: onlyBabyCries,
                    onTap: () => onLevelSelected(NoiseDetectionLevel.low),
                  ),
                  _ModeRow(
                    level: NoiseDetectionLevel.medium,
                    title: 'Standard',
                    description: 'Alerts you after mild noticeable sounds',
                    isSelected: level == NoiseDetectionLevel.medium,
                    onlyBabyCries: onlyBabyCries,
                    onTap: () => onLevelSelected(NoiseDetectionLevel.medium),
                  ),
                  _ModeRow(
                    level: NoiseDetectionLevel.high,
                    title: 'Max',
                    description: 'Alerts you as soon as a sound is detected',
                    isSelected: level == NoiseDetectionLevel.high,
                    onlyBabyCries: onlyBabyCries,
                    onTap: () => onLevelSelected(NoiseDetectionLevel.high),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.borderNormal),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
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
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, buttonBottom),
          child: Button(
            onPressed: onContinue,
            buttonLabel: Text(
              continueLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            variant: ButtonVariant.primary,
            size: ButtonSize.lg,
          ),
        ),
      ],
    );
  }
}

// Keep old name as alias so existing call sites compile unchanged
typedef NoiseDetectionBody = ModeSelectionBody;

// ── Segmented control ─────────────────────────────────────────────────────────

class _SegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: c.borderNormal),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < options.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: i == selectedIndex ? c.surfaceTertiary : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  options[i],
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: i == selectedIndex ? c.textPrimary : c.textTertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  final NoiseDetectionLevel level;
  final String title;
  final String description;
  final bool isSelected;
  final bool onlyBabyCries;
  final VoidCallback onTap;

  const _ModeRow({
    required this.level,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onlyBabyCries,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final borderRadius = BorderRadius.circular(16);
    return Material(
      color: isSelected ? c.surfacePrimary : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: c.borderNormal, width: isSelected ? 2 : 1),
      ),
      elevation: isSelected ? 2 : 0,
      shadowColor: c.overlayLevel1,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
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
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isSelected ? c.textPrimary : c.textSecondary,
                          ),
                        ),
                        if (onlyBabyCries) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: c.surfaceTertiary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Only baby cries',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
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

  String _assetFor(NoiseDetectionLevel level, bool isDark) {
    final number = switch (level) {
      NoiseDetectionLevel.low => '1',
      NoiseDetectionLevel.medium => '2',
      NoiseDetectionLevel.high => '3',
    };
    final variant = isDark ? 'dark' : 'light';
    return 'assets/icons/utility/$number$variant.svg';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        _assetFor(level, isDark),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
