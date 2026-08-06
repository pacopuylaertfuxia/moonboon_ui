import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';

/// V3 — The Glance Board · dashboard tiles
/// Bet: settings should answer before you tap — live-content tiles make the
/// overview a status board.
class V3TileDashboardPage extends StatefulWidget {
  const V3TileDashboardPage({super.key});

  @override
  State<V3TileDashboardPage> createState() => _V3TileDashboardPageState();
}

class _V3TileDashboardPageState extends State<V3TileDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Settings',
                      style: t.headlineLarge?.copyWith(fontSize: 34)),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: c.surfaceTertiary, shape: BoxShape.circle),
                    child: Icon(Icons.qr_code_rounded,
                        size: 20, color: c.textInverse),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Tile(
                      height: 190,
                      accent: true,
                      top: _BabyAvatar(),
                      title: 'Vera',
                      sub: '7 months\n2 caregivers · you own',
                      chip: 'Family',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Tile(
                      height: 190,
                      top: _InitialsAvatar('PP'),
                      title: 'Paco Puylaert',
                      sub: 'Father · Denmark\npaco@puylaert.dk',
                      chip: 'Profile',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Tile(
                      height: 160,
                      top: _IconBubble(Icons.help_outline_rounded),
                      title: 'Help',
                      sub: 'FAQs · manuals · support',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Tile(
                      height: 160,
                      top: _IconBubble(Icons.sentiment_satisfied_alt_rounded),
                      title: 'Feedback',
                      sub: 'Enjoying Moonboon?',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: c.surfacePrimary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: Text('Log out',
                      style: t.labelLarge?.copyWith(color: c.textTertiary)),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text('Delete account',
                    style: t.labelSmall?.copyWith(
                        color: c.feedbackError.withValues(alpha: 0.85))),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('v2.4.0',
                    style: t.bodySmall?.copyWith(
                        color: c.textTertiary.withValues(alpha: 0.5))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final double height;
  final Widget top;
  final String title;
  final String sub;
  final String? chip;
  final bool accent;

  const _Tile({
    required this.height,
    required this.top,
    required this.title,
    required this.sub,
    this.chip,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: height,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: accent
              ? c.surfaceTertiary.withValues(alpha: 0.55)
              : c.surfacePrimary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                top,
                if (chip != null)
                  Text(chip!.toUpperCase(),
                      style: t.labelSmall?.copyWith(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: c.textQuaternary,
                      )),
              ],
            ),
            const Spacer(),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.titleMedium?.copyWith(
                    fontFamily: 'KeplerStd',
                    fontSize: 21,
                    color: c.textPrimary)),
            const SizedBox(height: 4),
            Text(sub,
                style: t.bodySmall
                    ?.copyWith(fontSize: 12.5, color: c.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _BabyAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
          color: c.surfacePrimary, shape: BoxShape.circle),
      child: Icon(Icons.nightlight_round,
          size: 20, color: c.textQuaternary),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  const _InitialsAvatar(this.initials);

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: c.surfaceSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: c.borderNormal.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: c.textTertiary)),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  const _IconBubble(this.icon);

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: c.surfaceTertiary.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: c.textTertiary),
    );
  }
}
