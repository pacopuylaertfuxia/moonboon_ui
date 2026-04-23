import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/theme_colors.dart';
import '../setup_flow/component/noise_detection_body.dart';

class NoiseDetectionPickerButton extends StatelessWidget {
  final NoiseDetectionLevel level;
  final bool isUpdating;
  final VoidCallback? onTap;

  const NoiseDetectionPickerButton({
    super.key,
    required this.level,
    required this.isUpdating,
    this.onTap,
  });

  static String levelName(NoiseDetectionLevel level) {
    return switch (level) {
      NoiseDetectionLevel.low => 'Quiet',
      NoiseDetectionLevel.medium => 'Standard',
      NoiseDetectionLevel.high => 'Max',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isUpdating ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: context.color.textPrimary,
        disabledBackgroundColor: context.color.surfacePrimary,
        disabledForegroundColor: context.color.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            levelName(level),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.color.textPrimary),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 16,
            height: 16,
            child: isUpdating
                ? const CupertinoActivityIndicator(radius: 8)
                : SvgPicture.asset(
                    'assets/icons/utility/chevron-selector-vertical.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(context.color.brandSecondary, BlendMode.srcIn),
                  ),
          ),
        ],
      ),
    );
  }
}
