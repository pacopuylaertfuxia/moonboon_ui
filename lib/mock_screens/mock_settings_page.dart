import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/action_list_tile.dart';
import '../common/moonboon_scaffold.dart';
import '../theme/theme_colors.dart';

/// Mock of the Profile / Settings page — mirroring profile_page.dart.
class MockSettingsPage extends StatelessWidget {
  const MockSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MoonboonScaffold(
      appBar: MoonboonAppBar(title: 'Profile'),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: appBarHeight() + 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileCard(context),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  padding: EdgeInsets.zero,
                  childAspectRatio: 1.8,
                  children: [
                    ActionListTile(
                      title: 'Edit profile',
                      leadingIconAsset: 'assets/icons/utility/edit.svg',
                      variant: ActionListTileVariant.grid,
                      onTap: () {},
                    ),
                    ActionListTile(
                      title: 'Family',
                      leadingIconAsset: 'assets/icons/utility/family.svg',
                      variant: ActionListTileVariant.grid,
                      onTap: () {},
                    ),
                    ActionListTile(
                      title: 'Notifications',
                      leadingIconAsset: 'assets/icons/profile_notifications.svg',
                      variant: ActionListTileVariant.grid,
                      onTap: () {},
                    ),
                    ActionListTile(
                      title: 'Language',
                      leadingIconAsset: 'assets/icons/profile_language.svg',
                      variant: ActionListTileVariant.grid,
                      onTap: () {},
                    ),
                    ActionListTile(
                      title: 'Appearance',
                      leadingIconAsset: 'assets/icons/profile_appearance.svg',
                      variant: ActionListTileVariant.grid,
                      onTap: () {},
                    ),
                    ActionListTile(
                      title: 'Help',
                      leadingIconAsset: 'assets/icons/utility/circled_question.svg',
                      variant: ActionListTileVariant.grid,
                      onTap: () {},
                    ),
                    ActionListTile(
                      title: 'Log out',
                      leadingIconAsset: 'assets/icons/utility/door.svg',
                      variant: ActionListTileVariant.grid,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'v1.0.0 (1)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.color.textTertiary.withValues(alpha: 0.5),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _ProfileCard(BuildContext context) {
  final c = context.color;
  return Container(
    decoration: BoxDecoration(
      color: c.overlayLevel2,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header band with moon icon
        SizedBox(
          height: 120,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/utility/moon.svg',
              height: 38,
              width: 38,
              colorFilter: ColorFilter.mode(
                Theme.of(context).brightness == Brightness.dark
                    ? c.textPrimary.withValues(alpha: 0.75)
                    : c.textInverse.withValues(alpha: 0.75),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        // Avatar + name row
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar placeholder circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: c.surfaceQuaternary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: c.textTertiary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sarah Johnson',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: c.textTertiary,
                          ),
                    ),
                    Text(
                      'sarah@example.com',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: c.textTertiary.withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
