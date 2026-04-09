import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final double thumbWidth;
  final double thumbHeight;
  final double trackPadding;
  final double trackWidth;

  const ToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.thumbWidth = 39,
    this.thumbHeight = 24,
    this.trackPadding = 2,
    this.trackWidth = 64,
  });

  @override
  Widget build(BuildContext context) {
    final trackHeight = thumbHeight + trackPadding * 2;
    final thumbLeft = value ? trackWidth - trackPadding - thumbWidth : trackPadding;

    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: SizedBox(
          width: trackWidth,
          height: trackHeight,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                    color: value ? context.color.brandPrimary : context.color.textInactive,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: thumbLeft,
                child: Container(
                  width: thumbWidth,
                  height: thumbHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(thumbHeight / 2),
                    color: context.color.surfacePrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
