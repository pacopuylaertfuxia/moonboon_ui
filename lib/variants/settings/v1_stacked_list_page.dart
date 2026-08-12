import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';

/// V1 — The Calm Index · stacked list
/// Bet: parents come to Settings to get out fast — one serene, grouped list
/// with the baby pinned on top beats any clever layout.
class V1StackedListPage extends StatefulWidget {
  const V1StackedListPage({super.key});

  @override
  State<V1StackedListPage> createState() => _V1StackedListPageState();
}

class _V1StackedListPageState extends State<V1StackedListPage> {
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
              // Kepler page title + identity glance
              Text('Settings',
                  style: t.headlineLarge?.copyWith(fontSize: 34)),
              const SizedBox(height: 6),
              Text(
                'Paco Puylaert · paco@puylaert.dk',
                style: t.bodySmall?.copyWith(color: c.textTertiary),
              ),
              const SizedBox(height: 28),

              _SectionLabel('Family'),
              _CardGroup(children: [
                _Row(
                  leading: _BabyDot(),
                  title: 'Vera',
                  subtitle: '7 months',
                  onTap: () {},
                ),
                _Hairline(),
                _Row(
                  leading: _InitialsDot(initials: 'PP'),
                  title: 'Paco Puylaert',
                  trailingChip: 'Owner',
                  chevron: false,
                ),
                _Hairline(),
                _Row(
                  leading: _InitialsDot(initials: 'SP'),
                  title: 'Sofie Puylaert',
                  chevron: false,
                ),
                _Hairline(),
                _Row(
                  leading: _PlusDot(),
                  title: 'Invite a caregiver',
                  titleColor: c.textTertiary,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              _SectionLabel('Profile'),
              _CardGroup(children: [
                _Row(
                  icon: Icons.person_outline_rounded,
                  title: 'Your profile',
                  subtitle: 'Father · Denmark',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              _SectionLabel('Help'),
              _CardGroup(children: [
                _Row(
                  icon: Icons.menu_book_outlined,
                  title: 'Help center',
                  subtitle: 'FAQs, tracking, shipping, claims',
                  onTap: () {},
                ),
                _Hairline(),
                _Row(
                  icon: Icons.description_outlined,
                  title: 'User manuals',
                  onTap: () {},
                ),
                _Hairline(),
                _Row(
                  icon: Icons.mail_outline_rounded,
                  title: 'Contact support',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 24),

              _SectionLabel('Feedback'),
              _CardGroup(children: [
                _Row(
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  title: 'Enjoying Moonboon?',
                  subtitle: 'Tell us in ten seconds',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 36),

              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text('Log out',
                          style: t.labelLarge
                              ?.copyWith(color: c.textTertiary)),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {},
                      child: Text('Delete account',
                          style: t.labelMedium
                              ?.copyWith(color: c.feedbackError)),
                    ),
                    const SizedBox(height: 16),
                    Text('v2.4.0',
                        style: t.bodySmall?.copyWith(
                            color: c.textTertiary.withValues(alpha: 0.5))),
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

// ── pieces ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.color.textQuaternary,
              letterSpacing: 1.4,
            ),
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  final List<Widget> children;
  const _CardGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: children),
    );
  }
}

class _Hairline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
          height: 1,
          color: context.color.borderSubdued.withValues(alpha: 0.7)),
    );
  }
}

class _Row extends StatelessWidget {
  final Widget? leading;
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? trailingChip;
  final Color? titleColor;
  final bool chevron;
  final VoidCallback? onTap;

  const _Row({
    this.leading,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailingChip,
    this.titleColor,
    this.chevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            if (leading != null) leading!,
            if (icon != null)
              Icon(icon, size: 22, color: c.textQuaternary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: t.bodyMedium?.copyWith(
                          color: titleColor ?? c.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style:
                            t.bodySmall?.copyWith(color: c.textTertiary)),
                ],
              ),
            ),
            if (trailingChip != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.surfaceTertiary.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(trailingChip!,
                    style: t.labelSmall?.copyWith(color: c.textTertiary)),
              ),
            if (chevron && onTap != null)
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: c.textQuaternary),
          ],
        ),
      ),
    );
  }
}

class _BabyDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      width: 40,
      height: 40,
      decoration:
          BoxDecoration(color: c.surfaceTertiary, shape: BoxShape.circle),
      child: Icon(Icons.nightlight_round,
          size: 18, color: c.textInverse.withValues(alpha: 0.8)),
    );
  }
}

class _InitialsDot extends StatelessWidget {
  final String initials;
  const _InitialsDot({required this.initials});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: c.surfaceSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: c.borderNormal.withValues(alpha: 0.6)),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: c.textTertiary)),
    );
  }
}

class _PlusDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c.borderNormal),
      ),
      child: Icon(Icons.add_rounded, size: 20, color: c.textQuaternary),
    );
  }
}
