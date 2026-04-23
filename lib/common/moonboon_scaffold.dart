import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../theme/theme_colors.dart';

double appBarHeight() {
  // Approximation — on device the top padding is read from MediaQuery
  return kToolbarHeight;
}

class MoonboonScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final bool extendBodyBehindAppBar;
  final bool singleChildScrollViewBody;

  const MoonboonScaffold({
    super.key,
    required this.body,
    required this.appBar,
    this.extendBodyBehindAppBar = true,
    this.singleChildScrollViewBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final barHeight = topPadding + kToolbarHeight;

    final appBarWidget = this.appBar != null
        ? PreferredSize(
            preferredSize: Size.fromHeight(barHeight),
            child: Container(
              color: Colors.transparent,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    height: barHeight,
                    width: double.infinity,
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: this.appBar!,
                    ),
                  ),
                ),
              ),
            ),
          )
        : null;

    if (singleChildScrollViewBody) {
      return Scaffold(
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: appBarWidget,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: barHeight,
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          child: body,
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBarWidget,
      body: body,
    );
  }
}

class MoonboonAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? trailing;
  final EdgeInsets? padding;

  const MoonboonAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.trailing,
    this.padding,
  }) : assert(
         (title != null) != (titleWidget != null),
         'Exactly one of title or titleWidget must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    final resolvedTitle = DefaultTextStyle.merge(
      style: Theme.of(context).appBarTheme.titleTextStyle ?? const TextStyle(),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: titleWidget ?? Text(title!),
    );

    if (canPop) {
      return Padding(
        padding: padding ?? const EdgeInsets.only(right: 8),
        child: SizedBox(
          height: kToolbarHeight,
          child: CustomMultiChildLayout(
            delegate: _TrulyCenteredAppBarDelegate(middleSpacing: 16.0),
            children: [
              LayoutId(
                id: _AppBarSlot.leading,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/arrow_left.svg',
                      colorFilter: ColorFilter.mode(
                        context.color.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              LayoutId(id: _AppBarSlot.title, child: resolvedTitle),
              if (trailing != null)
                LayoutId(id: _AppBarSlot.trailing, child: trailing!),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: kToolbarHeight,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: resolvedTitle),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

enum _AppBarSlot { leading, title, trailing }

class _TrulyCenteredAppBarDelegate extends MultiChildLayoutDelegate {
  final double middleSpacing;
  _TrulyCenteredAppBarDelegate({required this.middleSpacing});

  @override
  void performLayout(Size size) {
    double leadingWidth = 0.0;
    if (hasChild(_AppBarSlot.leading)) {
      final s = layoutChild(_AppBarSlot.leading, BoxConstraints.loose(size));
      positionChild(_AppBarSlot.leading, Offset(0, (size.height - s.height) / 2 - 1));
      leadingWidth = s.width;
    }
    double trailingWidth = 0.0;
    if (hasChild(_AppBarSlot.trailing)) {
      final s = layoutChild(_AppBarSlot.trailing, BoxConstraints.loose(size));
      positionChild(_AppBarSlot.trailing, Offset(size.width - s.width, (size.height - s.height) / 2 - 1));
      trailingWidth = s.width;
    }
    if (hasChild(_AppBarSlot.title)) {
      final maxWidth = math.max(
        size.width - leadingWidth - trailingWidth - middleSpacing * 2,
        0.0,
      );
      final s = layoutChild(
        _AppBarSlot.title,
        BoxConstraints(maxWidth: maxWidth, maxHeight: size.height),
      );
      final minLeft = leadingWidth + middleSpacing;
      final maxLeft = size.width - trailingWidth - s.width - middleSpacing;
      final left = ((size.width - s.width) / 2).clamp(minLeft, maxLeft);
      positionChild(_AppBarSlot.title, Offset(left, (size.height - s.height) / 2));
    }
  }

  @override
  bool shouldRelayout(_TrulyCenteredAppBarDelegate old) => old.middleSpacing != middleSpacing;
}
