import 'package:flutter/material.dart';
import '../../common/button.dart';
import '../../theme/theme_colors.dart';

class StreamingConsentBody extends StatelessWidget {
  final VoidCallback onContinue;

  const StreamingConsentBody({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final buttonBottom = safeBottom > 0 ? safeBottom + 8 : 48.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Your device is ready\nto stream!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: c.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/streaming_ready.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, buttonBottom),
          child: Button(
            onPressed: onContinue,
            buttonLabel: Text(
              'Start streaming',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            variant: ButtonVariant.primary,
            size: ButtonSize.lg,
          ),
        ),
      ],
    );
  }
}
