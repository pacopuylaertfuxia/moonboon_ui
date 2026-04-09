import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

enum ButtonVariant { primary, secondary, destructive, ghost, outlined }

enum ButtonSize { standard, lg, medium, icon, custom }

Size _getSize(ButtonSize size) {
  switch (size) {
    case ButtonSize.lg:
      return const Size.fromHeight(60);
    case ButtonSize.icon:
      return const Size(60, 60);
    case ButtonSize.standard:
      return const Size(40, 40);
    case ButtonSize.medium:
      return const Size.fromHeight(52);
    case ButtonSize.custom:
      return const Size.fromHeight(40);
  }
}

ButtonStyle _getButtonStyle(
  ButtonVariant variant,
  ButtonSize size,
  BuildContext context, {
  required bool disabled,
}) {
  final borderRadius = BorderRadius.circular(100);
  final minSize = _getSize(size);

  switch (variant) {
    case ButtonVariant.primary:
      return TextButton.styleFrom(
        elevation: 0,
        backgroundColor: context.color.surfaceTertiary.withValues(
          alpha: disabled ? 0.5 : 1.0,
        ),
        foregroundColor: context.color.textPrimary,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      );
    case ButtonVariant.secondary:
      return TextButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: context.color.textPrimary,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: context.color.borderNormal),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      );
    case ButtonVariant.destructive:
      return TextButton.styleFrom(
        elevation: 0,
        backgroundColor: context.color.feedbackError.withValues(
          alpha: disabled ? 0.5 : 1.0,
        ),
        foregroundColor: context.color.textInverse,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      );
    case ButtonVariant.ghost:
      return TextButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: context.color.textSecondary,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      );
    case ButtonVariant.outlined:
      return TextButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: context.color.textPrimary,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: context.color.borderNormal),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      );
  }
}

class Button extends StatelessWidget {
  final Widget buttonLabel;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;

  const Button({
    super.key,
    required this.buttonLabel,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.lg,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getButtonStyle(variant, size, context, disabled: disabled);
    return TextButton(
      onPressed: disabled ? null : onPressed,
      style: style,
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.titleLarge ?? const TextStyle(),
        child: buttonLabel,
      ),
    );
  }
}
