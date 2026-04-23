import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

/// Shared device selection card used in both monitor and motor multi-device pickers.
/// Wrap with GestureDetector from the parent to handle taps.
class DevicePickCard extends StatelessWidget {
  final String imageAsset;
  final String serialNumber;
  final String label;

  const DevicePickCard({
    super.key,
    required this.imageAsset,
    required this.serialNumber,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.color.borderSubdued),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imageAsset, height: 140, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            'S/N: $serialNumber',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.color.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
