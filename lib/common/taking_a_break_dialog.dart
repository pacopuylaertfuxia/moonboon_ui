import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import 'button.dart';
import 'device_radius.dart';

Future<bool?> showTakingABreakDialog(BuildContext context) {
  return showDialog<bool?>(
    context: context,
    useSafeArea: false,
    builder: (context) => const _TakingABreakDialog(),
  );
}

class _TakingABreakDialog extends StatelessWidget {
  const _TakingABreakDialog();

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    final br = DeviceRadius.instance.bottomSheetRadius;

    return Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.fromLTRB(6, 0, 6, safeBottom > 0 ? safeBottom : 6),
      backgroundColor: context.color.surfacePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(32),
          topRight: const Radius.circular(32),
          bottomLeft: Radius.circular(br),
          bottomRight: Radius.circular(br),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Taking a break?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: context.color.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We\'ll pause the stream to save battery and data. You\'ll still get notified if your baby needs you.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.color.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Button(
              buttonLabel: Text(
                'Continue watching',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              variant: ButtonVariant.primary,
              size: ButtonSize.lg,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 12),
            Button(
              buttonLabel: Text(
                'Just notify me',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              variant: ButtonVariant.outlined,
              size: ButtonSize.lg,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            SizedBox(height: safeBottom > 0 ? 0 : 12),
          ],
        ),
      ),
    );
  }
}
