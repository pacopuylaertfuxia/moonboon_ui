import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme_colors.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({
    super.key,
    required this.batteryLevel,
    required this.isCharging,
    this.showBatteryLevel = false,
    this.isLowPowerMode = false,
    this.size = 24.0,
  });

  final double size;
  final double batteryLevel;
  final bool isCharging;
  final bool showBatteryLevel;
  final bool isLowPowerMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final labelMedium = Theme.of(context).textTheme.labelMedium;

    final icon = SvgPicture.asset(
      _getBatteryIconAsset(),
      height: size,
      width: size,
      colorMapper: _BatteryIconColorMapper(
        mainColor: colors.textPrimary,
        emptyIndicatorColor: const Color(0xFFD50000),
      ),
    );

    if (showBatteryLevel) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            '${(batteryLevel * 100).round()}%',
            style: labelMedium?.copyWith(color: colors.textPrimary),
          ),
        ],
      );
    }

    return icon;
  }

  String _getBatteryIconAsset() {
    const criticalPowerLevel = 0.10;
    if (isCharging) return 'assets/icons/battery/battery_charging.svg';
    if (isLowPowerMode && batteryLevel > criticalPowerLevel) return 'assets/icons/battery/battery_low_power_mode.svg';
    if (batteryLevel > 0.75) return 'assets/icons/battery/battery_full.svg';
    if (batteryLevel > 0.40) return 'assets/icons/battery/battery_mid.svg';
    if (batteryLevel > criticalPowerLevel) return 'assets/icons/battery/battery_low.svg';
    return 'assets/icons/battery/battery_empty.svg';
  }
}

class _BatteryIconColorMapper extends ColorMapper {
  final Color mainColor;
  final Color emptyIndicatorColor;
  const _BatteryIconColorMapper({required this.mainColor, required this.emptyIndicatorColor});

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    if (color == const Color(0xFF010101)) return mainColor;
    if (color == const Color(0xFFD50000)) return emptyIndicatorColor;
    return color;
  }
}
