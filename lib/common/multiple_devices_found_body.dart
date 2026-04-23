import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pair_device_body.dart';
import '../theme/theme_colors.dart';

/// Full-bleed horizontal card picker used in "Multiple [device] found" steps.
/// The scroll reaches the sheet edges — no extra horizontal padding is applied.
class MultipleDevicesFoundBody extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onBack;
  final List<Widget> cards;

  const MultipleDevicesFoundBody({
    super.key,
    required this.title,
    required this.description,
    required this.onBack,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSafeArea(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back button row
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Row(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/utility/chevron_left.svg',
                    colorFilter: ColorFilter.mode(
                      context.color.textPrimary,
                      BlendMode.srcIn,
                    ),
                    width: 24,
                    height: 24,
                  ),
                  onPressed: onBack,
                ),
              ],
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 16),
            child: Text(
              title,
              style: getTitleStyle(context),
              textAlign: TextAlign.center,
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              description,
              style: getBodyStyle(context),
              textAlign: TextAlign.center,
            ),
          ),
          // Full-width horizontal card scroll — no extra horizontal padding
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  cards[i],
                  if (i < cards.length - 1) const SizedBox(width: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
