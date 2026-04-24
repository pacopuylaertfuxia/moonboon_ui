import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

/// Shared shell for all setup/pairing bottom-sheet flows.
///
/// Wraps content in [AnimatedSize] so the sheet height smoothly follows
/// content changes. Overlays the stepper dots at the bottom when [step]
/// is non-null. Both the monitor setup flow and the motor pairing flow
/// use this widget — never inline the AnimatedSize + stepper pattern again.
class SetupSheetBody extends StatelessWidget {
  final Widget child;

  /// Current stepper position. Pass null to hide the stepper entirely.
  final int? step;
  final int totalSteps;
  final Color? backgroundColor;

  const SetupSheetBody({
    super.key,
    required this.child,
    this.step,
    required this.totalSteps,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: ColoredBox(
        color: backgroundColor ?? Colors.transparent,
        child: Builder(
          builder: (context) {
            final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;
            final showStepper = step != null && !keyboardUp;
            return Stack(
              children: [
                AnimatedPadding(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(bottom: showStepper ? 52.0 : 0.0),
                  child: child,
                ),
                if (showStepper)
                  Positioned(
                    bottom: 44,
                    left: 0,
                    right: 0,
                    child: Center(child: _buildStepper(context, step!, totalSteps)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepper(BuildContext context, int currentStep, int total) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final s = i + 1;
        final isCompleted = s < currentStep;
        final isCurrent = s == currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            width: isCurrent ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: (isCurrent || isCompleted)
                  ? context.color.surfaceTertiary
                  : context.color.surfaceTertiary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
