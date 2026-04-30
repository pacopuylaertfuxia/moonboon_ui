import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/button.dart';
import '../../theme/theme_colors.dart';

class WelcomeGiftScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeGiftScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: context.color.surfacePrimary.withValues(alpha: 0.95),
        padding: const EdgeInsets.only(left: 32, right: 32, top: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      'assets/icons/moonboon_plus_logo.svg',
                      width: 34,
                      height: 34,
                      colorFilter: ColorFilter.mode(
                        context.color.textInverse,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  'moonboon plus',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Our\nwelcome\ngift to you',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.noScaling,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 82,
                    height: 0.94,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Experience early access to Moonboon Plus features like remote streaming and more.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    height: 28 / 20,
                  ),
                ),
              ],
            ),
            Button(
              buttonLabel: Text(
                'Get started',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              variant: ButtonVariant.primary,
              size: ButtonSize.lg,
              onPressed: onGetStarted,
            ),
          ],
        ),
      ),
    );
  }
}
