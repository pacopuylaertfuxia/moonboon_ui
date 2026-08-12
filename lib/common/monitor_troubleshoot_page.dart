import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/theme_colors.dart';

Future<void> openMonitorTroubleshootPage(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const MonitorTroubleshootPage(),
    ),
  );
}

class MonitorTroubleshootPage extends StatelessWidget {
  const MonitorTroubleshootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.surfaceSecondary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/utility/chevron_left.svg',
                  colorFilter: ColorFilter.mode(
                    context.color.textPrimary,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: MediaQuery.of(context).viewPadding.bottom + 40,
                  left: 16,
                  right: 16,
                ),
                child: const _TroubleshootBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TroubleshootBody extends StatelessWidget {
  const _TroubleshootBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baby emotions row
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _BabyEmoji('assets/icons/baby_emotions_crying.svg'),
              SizedBox(width: 10),
              _BabyEmoji('assets/icons/baby_emotions_smiling.svg'),
              SizedBox(width: 10),
              _BabyEmoji('assets/icons/baby_emotions_happy.svg'),
              SizedBox(width: 10),
              _BabyEmoji('assets/icons/baby_emotions_sleeping.svg'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Title with italic "trouble"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: context.color.textSecondary,
              ),
              children: const [
                TextSpan(text: 'Having '),
                TextSpan(
                  text: 'trouble',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                TextSpan(text: ' setting up your monitor?'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Work through these steps one by one — most issues are fixed within the first two.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.color.textTertiary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _StepCard(
          icon: 'assets/icons/utility/icon_charging.svg',
          title: 'Make sure the monitor is charging',
          description:
              'The monitor must be plugged in throughout the entire setup. A low battery can interrupt the connection mid-process and cause it to fail.',
        ),
        const SizedBox(height: 8),
        const _StepCard(
          icon: 'assets/icons/utility/icon_bluetooth_setup.svg',
          title: 'Enable Bluetooth and stay close',
          description:
              'Bluetooth must be enabled on your phone. Stay within arm\'s reach of the monitor for the full duration of setup — Bluetooth range drops fast through walls.',
        ),
        const SizedBox(height: 8),
        const _StepCard(
          icon: 'assets/icons/utility/icon_wifi_setup.svg',
          title: 'Check your WiFi network',
          description:
              'The monitor only supports 2.4 GHz networks. If your router broadcasts both 2.4 GHz and 5 GHz under the same name, try connecting to the 2.4 GHz band separately. Also make sure your WiFi password is correct — it must be 8–63 characters.',
        ),
        const SizedBox(height: 8),
        const _StepCard(
          icon: 'assets/icons/utility/icon_reset.svg',
          title: 'Reset the monitor to factory settings',
          description:
              'Hold the button on the monitor for 15 seconds until the LED starts blinking white — this means it\'s ready to pair again. Then start the setup from the beginning.\n\nNote: this does not affect your account or other devices.',
        ),
        const SizedBox(height: 20),
        _ContactLine(),
      ],
    );
  }
}

class _BabyEmoji extends StatelessWidget {
  final String asset;
  const _BabyEmoji(this.asset);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 46,
      height: 46,
      colorFilter: ColorFilter.mode(context.color.brandPrimary, BlendMode.srcIn),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _StepCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: context.color.surfacePrimary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.color.borderNormal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 19,
                height: 19,
                colorFilter: ColorFilter.mode(
                  context.color.brandPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: context.color.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.color.textTertiary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: context.color.textTertiary,
    );
    return Center(
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          style: style,
          children: [
            const TextSpan(text: 'Still stuck? '),
            TextSpan(
              text: 'Contact support',
              style: style?.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: context.color.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
