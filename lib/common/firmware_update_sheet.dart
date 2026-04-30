import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import 'button.dart';
import 'modal_sheet.dart';

Future<void> showFirmwareUpdateSheet(
  BuildContext context, {
  required VoidCallback onUpdate,
  required VoidCallback onContinueWithout,
}) {
  return ModalSheet.show<void>(
    context: context,
    background: ModalSheetBackground.cream,
    child: _FirmwareUpdateContent(
      onUpdate: onUpdate,
      onContinueWithout: onContinueWithout,
    ),
  );
}

class _FirmwareUpdateContent extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback onContinueWithout;

  const _FirmwareUpdateContent({
    required this.onUpdate,
    required this.onContinueWithout,
  });

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).viewPadding.bottom > 0
        ? MediaQuery.of(context).viewPadding.bottom + 8
        : 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/illustrations/monitor/illustration_monitor_front.png',
          width: 160,
        ),
        const SizedBox(height: 24),
        Text(
          'Update required',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: context.color.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'A firmware update is available to improve your monitor\'s performance and add the latest features.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: context.color.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Button(
          buttonLabel: Text(
            'Update firmware',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          variant: ButtonVariant.primary,
          size: ButtonSize.lg,
          onPressed: () {
            Navigator.of(context).pop();
            onUpdate();
          },
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            onContinueWithout();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 16, 24, safeBottom),
            color: Colors.transparent,
            alignment: Alignment.center,
            child: Text(
              'Continue without updating',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
