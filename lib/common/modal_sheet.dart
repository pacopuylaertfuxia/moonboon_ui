import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import 'device_radius.dart';

enum ModalSheetBackground {
  white,
  cream,
}

Color getModalSheetBackgroundColor(
  BuildContext context,
  ModalSheetBackground background,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return background == ModalSheetBackground.cream || isDark
      ? context.color.surfaceSecondary
      : context.color.surfacePrimary;
}

Color _getModalSheetCloseButtonColor(
  BuildContext context,
  ModalSheetBackground background,
) {
  return background == ModalSheetBackground.cream ||
          Theme.of(context).brightness == Brightness.dark
      ? context.color.surfacePrimary
      : context.color.surfaceSecondary;
}

class ModalSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? description;
  final VoidCallback? onClose;
  final double? maxHeight;
  final bool hasPadding;
  final Duration duration;
  final double? headerPadding;
  final bool hasCloseButton;
  final ModalSheetBackground background;

  const ModalSheet({
    super.key,
    required this.child,
    this.title,
    this.description,
    this.onClose,
    this.maxHeight,
    this.hasPadding = true,
    this.duration = const Duration(milliseconds: 250),
    this.headerPadding = 24,
    this.hasCloseButton = false,
    required this.background,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? description,
    Widget? footer,
    VoidCallback? onClose,
    bool hasPadding = true,
    Duration duration = const Duration(milliseconds: 250),
    double? headerPadding,
    bool hasCloseButton = false,
    Color? barrierColor,
    bool isDismissible = true,
    bool enableDrag = true,
    ModalSheetBackground background = ModalSheetBackground.cream,
    bool useRootNavigator = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierColor:
          barrierColor ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withValues(alpha: 0.75)
              : Colors.black38),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(6.0),
        child: ModalSheet(
          title: title,
          description: description,
          onClose: onClose,
          hasPadding: hasPadding,
          duration: duration,
          hasCloseButton: hasCloseButton,
          background: background,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).viewPadding.bottom > 0
        ? MediaQuery.of(context).viewPadding.bottom
        : 16.0;

    final padding = hasPadding
        ? EdgeInsets.fromLTRB(
            16,
            16,
            16,
            bottomSafeArea,
          )
        : EdgeInsets.zero;

    // Matches production: bottom corners = device screen corner radius - 4.
    // 0 = flat (older Android/devices with no rounded corners).
    final bottomRadius = DeviceRadius.instance.bottomSheetRadius;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(32),
        topRight: const Radius.circular(32),
        bottomLeft: Radius.circular(bottomRadius),
        bottomRight: Radius.circular(bottomRadius),
      ),
      child: _AnimatedSizeOrNot(
        duration: duration,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? MediaQuery.of(context).size.height - 60,
          ),
          decoration: BoxDecoration(
            color: getModalSheetBackgroundColor(context, background),
          ),
          child: Stack(
            children: [
              Padding(
                padding: padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Flexible(child: child)],
                ),
              ),
              if (hasCloseButton)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: _getModalSheetCloseButtonColor(
                            context,
                            background,
                          ),
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Convenience components for building modal sheets
class ModalSheetHeader extends StatelessWidget {
  final Widget? title;
  final Widget? description;
  final List<Widget>? actions;

  const ModalSheetHeader({
    super.key,
    this.title,
    this.description,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) title!,
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      description!,
                    ],
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ],
      ),
    );
  }
}

class ModalSheetFooter extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  const ModalSheetFooter({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(mainAxisAlignment: mainAxisAlignment, children: children),
    );
  }
}

class ModalSheetTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const ModalSheetTitle({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style:
          style ??
          theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
    );
  }
}

class ModalSheetDescription extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const ModalSheetDescription({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style:
          style ??
          theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
    );
  }
}

class _AnimatedSizeOrNot extends StatelessWidget {
  final Duration duration;
  final Widget child;

  const _AnimatedSizeOrNot({required this.duration, required this.child});

  @override
  Widget build(BuildContext context) {
    if (duration == Duration.zero) return child;
    return AnimatedSize(duration: duration, child: child);
  }
}
