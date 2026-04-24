import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme_colors.dart';

// Matches production MoonboonBottomNavigationBar — no GoRouter, no haptics.

const double _navItemWidth = 102;
const double _navItemHeight = 62;
const double mockNavBarWidth = 294;
const double mockNavBarHeight = 70;

double mockNavBarBottomPadding(BuildContext context) =>
    MediaQuery.of(context).padding.bottom +
    (defaultTargetPlatform == TargetPlatform.android ? 8.0 : 0.0);

/// Total height consumed at the bottom by the nav pill + safe area.
double mockNavBarTotalHeight(BuildContext context) =>
    mockNavBarHeight + mockNavBarBottomPadding(context);

class MockBottomNav extends StatelessWidget {
  /// 0 = Home, 1 = Track, 2 = Devices
  final int activeIndex;
  const MockBottomNav({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final activeColor = c.textPrimary;
    final inactiveColor = c.textSecondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: mockNavBarBottomPadding(context)),
      child: SizedBox(
        width: mockNavBarWidth,
        height: mockNavBarHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Material(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.7)
                  : const Color(0xFFFAFDFF).withValues(alpha: 0.7),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: _NavItem(
                      index: 0,
                      icon: 'assets/icons/nav_bar_home.svg',
                      label: 'Home',
                      activeIndex: activeIndex,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: _NavItem(
                      index: 1,
                      icon: 'assets/icons/nav_bar_track.svg',
                      label: 'Track',
                      activeIndex: activeIndex,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: _NavItem(
                        index: 2,
                        icon: 'assets/icons/nav_bar_devices.svg',
                        label: 'Devices',
                        activeIndex: activeIndex,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int activeIndex;
  final String icon;
  final String label;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.index,
    required this.activeIndex,
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final isSelected = activeIndex == index;
    final color = isSelected ? activeColor : inactiveColor;

    return SizedBox(
      width: _navItemWidth,
      height: _navItemHeight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: c.overlayBrand.withValues(alpha: isSelected ? 0.5 : 0.0),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
