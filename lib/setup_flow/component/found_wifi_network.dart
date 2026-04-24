import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme_colors.dart';

class FoundWifiNetwork extends StatelessWidget {
  final String ssid;

  const FoundWifiNetwork({super.key, required this.ssid});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              ssid,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.color.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/icons/utility/chevron_right.svg',
              colorFilter: ColorFilter.mode(context.color.brandSecondary, BlendMode.srcIn),
              width: 18,
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}
