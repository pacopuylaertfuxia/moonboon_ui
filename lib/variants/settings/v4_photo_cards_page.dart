import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';

/// V4 — The Album · full-bleed imagery cards
/// Bet: extend the Devices-page photographic language to people — Settings
/// feels like a family album, not admin.
class V4PhotoCardsPage extends StatefulWidget {
  const V4PhotoCardsPage({super.key});

  @override
  State<V4PhotoCardsPage> createState() => _V4PhotoCardsPageState();
}

class _V4PhotoCardsPageState extends State<V4PhotoCardsPage> {
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
              Text('Settings',
                  style: t.headlineLarge?.copyWith(fontSize: 34)),
              const SizedBox(height: 24),

              // Family album card — warm in-context photography of Vera
              _AlbumCard(
                media: Image.asset(
                  'assets/images/streaming_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                label: '2 CAREGIVERS',
                title: 'Vera · 7 months',
                action: 'Manage',
              ),
              const SizedBox(height: 16),

              // You card — no photo set yet → first-class placeholder
              _AlbumCard(
                media: Container(
                  color: c.surfaceTertiary,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text('PP',
                          style: t.headlineLarge?.copyWith(
                            fontSize: 44,
                            color: c.textInverse.withValues(alpha: 0.65),
                          )),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: c.surfacePrimary.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('Add a photo',
                              style: t.labelSmall
                                  ?.copyWith(color: c.textTertiary)),
                        ),
                      ),
                    ],
                  ),
                ),
                label: 'FATHER · DENMARK',
                title: 'Paco Puylaert',
                action: 'Edit profile',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _SmallCard(
                      icon: Icons.help_outline_rounded,
                      title: 'Help',
                      sub: 'FAQs · manuals · support',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SmallCard(
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      title: 'Feedback',
                      sub: 'Enjoying Moonboon?',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    Text('Log out',
                        style:
                            t.labelLarge?.copyWith(color: c.textTertiary)),
                    const SizedBox(height: 12),
                    Text('Delete account',
                        style: t.labelSmall?.copyWith(
                            color: c.feedbackError.withValues(alpha: 0.85))),
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

class _AlbumCard extends StatelessWidget {
  final Widget media;
  final String label;
  final String title;
  final String action;

  const _AlbumCard({
    required this.media,
    required this.label,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Column(
        children: [
          SizedBox(height: 210, width: double.infinity, child: media),
          Container(
            width: double.infinity,
            color: c.surfacePrimary,
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: t.labelSmall?.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: c.textQuaternary,
                          )),
                      const SizedBox(height: 4),
                      Text(title,
                          style: t.titleMedium?.copyWith(
                              fontFamily: 'KeplerStd',
                              fontSize: 22,
                              color: c.textPrimary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: c.surfaceTertiary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        Text(action,
                            style: t.labelMedium
                                ?.copyWith(color: c.textInverse)),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded,
                            size: 16, color: c.textInverse),
                      ],
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

class _SmallCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  const _SmallCard(
      {required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.surfacePrimary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: c.textQuaternary),
            const SizedBox(height: 14),
            Text(title,
                style: t.titleMedium?.copyWith(
                    fontFamily: 'KeplerStd',
                    fontSize: 20,
                    color: c.textPrimary)),
            const SizedBox(height: 2),
            Text(sub,
                style: t.bodySmall
                    ?.copyWith(fontSize: 12.5, color: c.textTertiary)),
          ],
        ),
      ),
    );
  }
}
