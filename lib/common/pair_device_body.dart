import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'button.dart';
import 'wrap_if.dart';
import '../theme/theme_colors.dart';

const double pairDeviceBodyTopPadding = 48;
const double pairDeviceBodyBottomPadding = 32;
const double horizontalPadding = 16.0;
const double bottomSafeArea = 32.0;

TextStyle? getTitleStyle(BuildContext context) {
  return Theme.of(
    context,
  ).textTheme.headlineSmall?.copyWith(color: context.color.textSecondary);
}

TextStyle? getBodyStyle(BuildContext context) {
  return Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(
    color: context.color.textSecondary,
    height: 1.5,
    fontSize: 18,
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
        bottom: withBottomPadding ? bottomSafeArea : 0,
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
                          icon: const Icon(Icons.arrow_back, size: 24),
                          onPressed: onBackButtonPressed,
                        ),
                      const Spacer(),
                      if (onCloseButtonPressed != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 24),
                            onPressed: onCloseButtonPressed,
                          ),
                        ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 44),
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
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 8.0,
                  bottom: assetBottomPadding,
                  left: horizontalPadding,
                  right: horizontalPadding,
                ),
                child: Center(
                  heightFactor: 1.0,
                  widthFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: isSvgAsset
                        ? SvgPicture.asset(asset!)
                        : Image.asset(asset!),
                  ),
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
                                style: Theme.of(context).textTheme.titleLarge,
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
                          style: Theme.of(context).textTheme.titleLarge
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

  const PairDeviceErrorBody({
    super.key,
    required this.title,
    required this.description,
    this.withBottomPadding = true,
    required this.primaryButtonLabel,
    required this.onPrimaryButtonPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: withBottomPadding ? bottomSafeArea : 0,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            Image.asset('assets/crying_baby.png', height: 92),
            const SizedBox(height: 24),
            Text(
              title,
              style: getTitleStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: getBodyStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Button(
              onPressed: isLoading ? null : onPrimaryButtonPressed,
              buttonLabel: isLoading
                  ? const CupertinoActivityIndicator(radius: 16)
                  : Text(
                      primaryButtonLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
              variant: ButtonVariant.primary,
              size: ButtonSize.lg,
            ),
          ],
        ),
      ),
    );
  }
}
