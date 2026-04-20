import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'button.dart';
import 'wrap_if.dart';
import '../theme/theme_colors.dart';

const double pairDeviceBodyTopPadding = 48;
const double pairDeviceBodyBottomPadding = 32;
const double horizontalPadding = 16.0;

/// Matches production device.dart: padding.bottom + 8, fallback 16
double bottomSafeArea(BuildContext context) {
  final bottom = MediaQuery.of(context).padding.bottom;
  return bottom > 0 ? bottom + 8 : 48.0;
}

TextStyle? getTitleStyle(BuildContext context) {
  return Theme.of(
    context,
  ).textTheme.headlineSmall?.copyWith(color: context.color.textPrimary);
}

TextStyle? getBodyStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: context.color.textSecondary,
    height: 1.5,
  );
}

class PairDeviceBody extends StatelessWidget {
  final String? title;
  final String? asset;
  final String? description;
  final Widget? descriptionWidget;
  final String? primaryButtonLabel;
  final String? secondaryButtonLabel;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Widget? child;
  final bool assetBackground;
  final bool isLoading;
  final double minHeight;
  final bool withBottomPadding;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onCloseButtonPressed;
  final double assetBottomPadding;
  final bool isSvgAsset;
  final double? titleBottomPadding;

  PairDeviceBody({
    super.key,
    this.title,
    this.asset,
    this.description,
    this.descriptionWidget,
    this.primaryButtonLabel,
    this.secondaryButtonLabel,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.child,
    this.assetBackground = true,
    this.isLoading = false,
    this.minHeight = 460,
    this.withBottomPadding = true,
    this.assetBottomPadding = 32,
    this.onBackButtonPressed,
    this.onCloseButtonPressed,
    this.titleBottomPadding,
  }) : isSvgAsset = asset?.contains('.svg') ?? false;

  @override
  Widget build(BuildContext context) {
    final titleStyle = getTitleStyle(context);
    final bodyStyle = getBodyStyle(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: withBottomPadding ? bottomSafeArea(context) : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              if (onBackButtonPressed != null || onCloseButtonPressed != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8),
                  child: Row(
                    children: [
                      if (onBackButtonPressed != null)
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/utility/chevron_left.svg',
                            colorFilter: ColorFilter.mode(context.color.textPrimary, BlendMode.srcIn),
                            width: 24,
                            height: 24,
                          ),
                          onPressed: onBackButtonPressed,
                        ),
                      const Spacer(),
                      if (onCloseButtonPressed != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: IconButton(
                            icon: SvgPicture.asset(
                            'assets/icons/utility/close.svg',
                            colorFilter: ColorFilter.mode(context.color.textPrimary, BlendMode.srcIn),
                            width: 24,
                            height: 24,
                          ),
                            onPressed: onCloseButtonPressed,
                          ),
                        ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 12),
              if (title != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding + 32,
                    right: horizontalPadding + 32,
                    bottom: titleBottomPadding ?? 24,
                  ),
                  child: Text(
                    title!,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                const SizedBox.shrink(),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: 24,
                  ),
                  child: Text(
                    description!,
                    style: bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          if (asset != null)
            Padding(
              padding: EdgeInsets.only(
                top: 8.0,
                bottom: assetBottomPadding,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              child: Center(
                child: SizedBox(
                  height: 190,
                  child: isSvgAsset
                      ? SvgPicture.asset(asset!, fit: BoxFit.contain)
                      : Image.asset(asset!, fit: BoxFit.contain),
                ),
              ),
            ),
          if (descriptionWidget != null)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 24.0,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              child: descriptionWidget!,
            ),
          if (child != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: child,
            ),
          if (primaryButtonLabel != null || secondaryButtonLabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (primaryButtonLabel != null)
                    WrapIf(
                      condition:
                          child == null && description == null && asset != null,
                      wrapper: (context, child) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: child,
                      ),
                      child: Button(
                        onPressed: isLoading ? null : onPrimaryButtonPressed,
                        buttonLabel: isLoading
                            ? const CupertinoActivityIndicator(radius: 16)
                            : Text(
                                primaryButtonLabel!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                        variant: ButtonVariant.primary,
                        size: ButtonSize.lg,
                      ),
                    ),
                  if (secondaryButtonLabel != null &&
                      primaryButtonLabel != null)
                    const SizedBox(height: 8),
                  if (secondaryButtonLabel != null)
                    GestureDetector(
                      onTap: onSecondaryButtonPressed,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          secondaryButtonLabel!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                decoration: TextDecoration.underline,
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PairDeviceErrorBody extends StatelessWidget {
  final String title;
  final String description;
  final bool withBottomPadding;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryButtonPressed;
  final bool isLoading;
  final VoidCallback? onTroubleshoot;

  const PairDeviceErrorBody({
    super.key,
    required this.title,
    required this.description,
    this.withBottomPadding = true,
    required this.primaryButtonLabel,
    required this.onPrimaryButtonPressed,
    this.isLoading = false,
    this.onTroubleshoot,
  });

  @override
  Widget build(BuildContext context) {
    final safeBottom = withBottomPadding ? bottomSafeArea(context) : 32.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, safeBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          // Image + title + description
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  spacing: 24,
                  children: [
                    Image.asset('assets/crying_baby.png', height: 92),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: context.color.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.color.textSecondary,
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // Buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Button(
                onPressed: isLoading ? null : onPrimaryButtonPressed,
                buttonLabel: isLoading
                    ? const CupertinoActivityIndicator(radius: 16)
                    : Text(primaryButtonLabel),
                variant: ButtonVariant.primary,
                size: ButtonSize.lg,
              ),
              if (onTroubleshoot != null)
                GestureDetector(
                  onTap: onTroubleshoot,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      'Trouble connecting?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: context.color.textPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
