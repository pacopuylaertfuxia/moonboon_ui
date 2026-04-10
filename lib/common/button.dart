import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/theme_colors.dart';

/// Luminance-based overlay color — matches production color_utils.dart
Color getOverlayColor(Color? backgroundColor, BuildContext context) {
  final bgColor = backgroundColor ?? context.color.surfaceTertiary;
  if ((bgColor.a * 255.0).round() & 0xff == 0) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.12);
  }
  final luminance = bgColor.computeLuminance();
  return luminance < 0.5
      ? Colors.white.withValues(alpha: 0.12)
      : Colors.black.withValues(alpha: 0.12);
}

enum ButtonVariant { primary, secondary, destructive, ghost, outlined }

enum ButtonSize { standard, lg, medium, icon, custom }

Size _getSize(ButtonSize size, {double? customHeight, double? customWidth}) {
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
      if (customHeight != null && customWidth != null) {
        return Size(customWidth, customHeight);
      } else if (customHeight != null) {
        return Size.fromHeight(customHeight);
      } else if (customWidth != null) {
        return Size.fromWidth(customWidth);
      }
      return const Size.fromHeight(40); // fallback
  }
}

TextStyle? _getTextStyle(
  ButtonSize size,
  BuildContext context,
) {
  switch (size) {
    case ButtonSize.lg:
      return Theme.of(context).textTheme.titleMedium;
    case ButtonSize.medium:
      return Theme.of(context).textTheme.labelLarge;
    case ButtonSize.icon:
    case ButtonSize.standard:
    case ButtonSize.custom:
      return Theme.of(context).textTheme.labelMedium;
  }
}

ButtonStyle getButtonStyle(
  ButtonVariant variant,
  ButtonSize size,
  BuildContext context, {
  double? customHeight,
  double? customWidth,
  double? customRadius,
  Color? backgroundColor,
  TextStyle? labelStyle,
  required bool disabled,
}) {
  final borderRadius = BorderRadius.circular(customRadius ?? 100);
  final minSize = _getSize(
    size,
    customHeight: customHeight,
    customWidth: customWidth,
  );
  TextStyle? textStyle;
  if (labelStyle == null) {
    textStyle = _getTextStyle(size, context);
  }

  switch (variant) {
    case ButtonVariant.primary:
      return TextButton.styleFrom(
        elevation: 0,
        backgroundColor:
            backgroundColor ??
            context.color.surfaceTertiary.withValues(
              alpha: disabled ? 0.5 : 1.0,
            ),
        foregroundColor: context.color.textPrimary,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        textStyle: textStyle,
        overlayColor: getOverlayColor(backgroundColor, context),
      );
    case ButtonVariant.secondary:
      return OutlinedButton.styleFrom(
        backgroundColor:
            backgroundColor ??
            mutedApricot.withValues(alpha: disabled ? 0.5 : 1.0),
        foregroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        side: BorderSide.none,
        textStyle: textStyle,
        overlayColor: getOverlayColor(backgroundColor, context),
      );
    case ButtonVariant.destructive:
      return ElevatedButton.styleFrom(
        backgroundColor:
            backgroundColor ??
            context.color.feedbackError.withValues(alpha: disabled ? 0.5 : 1.0),
        foregroundColor: context.color.textInverse,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        elevation: 0,
        textStyle: textStyle,
      );
    case ButtonVariant.ghost:
      return TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        textStyle: textStyle,
      );
    case ButtonVariant.outlined:
      return OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: context.color.textPrimary,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: context.color.borderNormal,
          ),
        ),
        textStyle: textStyle,
      );
  }
}

class Button extends StatelessWidget {
  final Widget? icon;
  final Widget? buttonLabel;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final bool shake;
  final double? customHeight;
  final double? customWidth;
  final double? customRadius;
  final Color? backgroundColor;
  final TextStyle? labelStyle;

  const Button({
    super.key,
    this.icon,
    this.buttonLabel,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.standard,
    this.disabled = false,
    this.shake = false,
    this.customHeight,
    this.customWidth,
    this.customRadius,
    this.backgroundColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style = getButtonStyle(
      variant,
      size,
      context,
      customHeight: customHeight,
      customWidth: customWidth,
      customRadius: customRadius,
      backgroundColor: backgroundColor,
      labelStyle: labelStyle,
      disabled: disabled,
    );
    final effectiveOnPressed = disabled
        ? null
        : () {
            onPressed?.call();
          };

    Widget? buttonLabelWrapped = buttonLabel;
    if (buttonLabel != null && labelStyle != null) {
      buttonLabelWrapped = DefaultTextStyle(
        style: labelStyle!,
        child: buttonLabel!,
      );
    }

    if (icon != null && buttonLabel != null) {
      // Icon + label
      switch (variant) {
        case ButtonVariant.primary:
        case ButtonVariant.destructive:
          return ElevatedButton.icon(
            style: style,
            onPressed: effectiveOnPressed,
            icon: icon!,
            label: buttonLabelWrapped!,
          );
        case ButtonVariant.secondary:
          return OutlinedButton.icon(
            style: style,
            onPressed: effectiveOnPressed,
            icon: icon!,
            label: buttonLabelWrapped!,
          );
        case ButtonVariant.ghost:
        case ButtonVariant.outlined:
          return TextButton.icon(
            style: style,
            onPressed: effectiveOnPressed,
            icon: icon!,
            label: buttonLabelWrapped!,
          );
      }
    }

    if (icon != null && buttonLabel == null) {
      // Icon only
      return SizedBox(
        width: customWidth,
        height: customHeight,
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: IconButton(
            icon: icon!,
            onPressed: disabled
                ? null
                : () {
                    onPressed?.call();
                  },
            style: style,
          ),
        ),
      );
    }

    // Label only or neither
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.destructive:
        return ElevatedButton(
          style: style,
          onPressed: effectiveOnPressed,
          child: buttonLabelWrapped ?? const SizedBox.shrink(),
        );
      case ButtonVariant.secondary:
        return OutlinedButton(
          style: style,
          onPressed: effectiveOnPressed,
          child: buttonLabelWrapped ?? const SizedBox.shrink(),
        );
      case ButtonVariant.ghost:
      case ButtonVariant.outlined:
        return TextButton(
          style: style,
          onPressed: effectiveOnPressed,
          child: buttonLabelWrapped ?? const SizedBox.shrink(),
        );
    }
  }
}
