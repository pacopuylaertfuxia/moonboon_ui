import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_colors.dart';

class FoundWifiNetwork extends StatelessWidget {
  final String ssid;

  const FoundWifiNetwork({super.key, required this.ssid});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDarkMode
          ? context.color.surfaceSecondary
          : context.color.surfacePrimary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              ssid,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.color.surfaceTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
