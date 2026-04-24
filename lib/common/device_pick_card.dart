import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../strings/app_strings.dart';
import '../theme/theme_colors.dart';

/// Full-bleed device picker card — matches the "Multiple found" Figma spec.
/// 322×409px, rotated product image, serial number + Connect pill at bottom.
/// Wrap with a margin/padding in the parent scroll view.
class DevicePickCard extends StatelessWidget {
  final String imageAsset;
  final String serialNumber;
  final VoidCallback onConnect;

  static const double _cardWidth = 322;
  static const double _cardHeight = 409;

  const DevicePickCard({
    super.key,
    required this.imageAsset,
    required this.serialNumber,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      height: _cardHeight,
      decoration: BoxDecoration(
        color: context.color.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 2),
            blurRadius: 32,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Oversized rotated product image — fills the top ~80% of the card
          Positioned(
            left: -168.55,
            top: -181.45,
            width: 600.78,
            height: 637.80,
            child: Center(
              child: Transform.rotate(
                angle: math.pi / 6, // 30°
                child: SizedBox(
                  width: 302.09,
                  height: 377.93,
                  child: Image.asset(imageAsset, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          // Info row — pinned 341px from top (68px from bottom)
          Positioned(
            left: 20,
            right: 20,
            top: 341,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Serial number label + value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.text.serial_number,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.color.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        serialNumber,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.color.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Connect pill
                GestureDetector(
                  onTap: onConnect,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.color.surfaceTertiary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      context.text.connect,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
