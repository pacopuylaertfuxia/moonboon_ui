import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../setup_flow/component/noise_detection_body.dart';
import '../../theme/theme_colors.dart';

class NoiseDetectionIndicator extends StatelessWidget {
  final NoiseDetectionLevel level;
  final double size;

  const NoiseDetectionIndicator({super.key, required this.level, required this.size});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceQuaternary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset(
        'assets/icons/utility/alert_mode.svg',
        height: size,
        width: size,
        colorMapper: _NoiseDetectionIconMapper(
          level: level,
          bellColor: c.textPrimary,
          ringColor: c.surfacePrimary,
        ),
      ),
    );
  }
}

class _NoiseDetectionIconMapper extends ColorMapper {
  final NoiseDetectionLevel level;
  final Color bellColor;
  final Color ringColor;

  const _NoiseDetectionIconMapper({
    required this.level,
    required this.bellColor,
    required this.ringColor,
  });

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    return switch (id) {
      'bell' => bellColor,
      'ring-inner' => switch (level) {
        NoiseDetectionLevel.high   => ringColor.withAlpha(150),
        NoiseDetectionLevel.medium => ringColor.withAlpha(50),
        NoiseDetectionLevel.low    => ringColor.withAlpha(25),
      },
      'ring-middle' => switch (level) {
        NoiseDetectionLevel.high   => ringColor.withAlpha(50),
        NoiseDetectionLevel.medium => ringColor.withAlpha(25),
        NoiseDetectionLevel.low    => Colors.transparent,
      },
      'ring-outer' => switch (level) {
        NoiseDetectionLevel.high   => ringColor.withAlpha(25),
        NoiseDetectionLevel.medium => Colors.transparent,
        NoiseDetectionLevel.low    => Colors.transparent,
      },
      _ => color,
    };
  }
}
