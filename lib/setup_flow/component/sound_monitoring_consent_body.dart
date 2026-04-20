import 'package:flutter/material.dart';
import '../../common/button.dart';
import '../../theme/theme_colors.dart';

class SoundMonitoringConsentBody extends StatelessWidget {
  final VoidCallback onGiveConsent;
  final VoidCallback onDisable;

  const SoundMonitoringConsentBody({
    super.key,
    required this.onGiveConsent,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final buttonBottom = safeBottom > 0 ? safeBottom + 8 : 48.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Allow sound\nmonitoring',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: c.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: c.textSecondary,
                    height: 1.5,
                  ),
                  children: const [
                    TextSpan(
                      text:
                          'To use features like cry detection, the monitor needs your permission to process short audio clips. These recordings are stored securely, never shared, and are only used to improve detection and receive your feedback. Learn more in ',
                    ),
                    TextSpan(
                      text: 'privacy settings.',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Button(
            onPressed: onGiveConsent,
            buttonLabel: Text(
              'Give consent',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            variant: ButtonVariant.primary,
            size: ButtonSize.lg,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onDisable,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 16, 16, buttonBottom),
            alignment: Alignment.center,
            child: Text(
              'Disable',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration: TextDecoration.underline,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
