import 'package:flutter/material.dart';
import '../../theme/theme_colors.dart';

class TemperatureIndicator extends StatelessWidget {
  const TemperatureIndicator({super.key, required this.temperature});

  final int? temperature;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        temperature != null ? '$temperature°' : '-',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.textPrimary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
