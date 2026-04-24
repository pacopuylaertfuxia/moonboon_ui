import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import 'adaptive_indicators/battery_indicator.dart';
import 'adaptive_indicators/signal_indicator.dart';
import 'adaptive_indicators/temperature_indicator.dart';


class TelemetryPanel extends StatelessWidget {
  final double batteryLevel;
  final bool isCharging;
  final bool isLowPowerMode;
  final double signalStrength;
  final int? temperature;

  const TelemetryPanel({
    super.key,
    required this.batteryLevel,
    required this.isCharging,
    required this.signalStrength,
    required this.temperature,
    this.isLowPowerMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final battery = BatteryIndicator(
      batteryLevel: batteryLevel,
      isCharging: isCharging,
      isLowPowerMode: isLowPowerMode,
      showBatteryLevel: true,
    );
    final signal = SignalIndicator(signalStrength: signalStrength);
    final temp = TemperatureIndicator(temperature: temperature);

    return Row(
      spacing: 8,
      children: [
        Expanded(child: _TelemetryPanelItem(battery)),
        Expanded(child: _TelemetryPanelItem(signal)),
        Expanded(child: _TelemetryPanelItem(temp)),
      ],
    );
  }
}

class _TelemetryPanelItem extends StatelessWidget {
  final Widget child;
  const _TelemetryPanelItem(this.child);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(9999);
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.color.surfacePrimary,
          borderRadius: borderRadius,
          border: Border.all(color: context.color.surfaceQuaternary),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: child,
      ),
    );
  }
}
