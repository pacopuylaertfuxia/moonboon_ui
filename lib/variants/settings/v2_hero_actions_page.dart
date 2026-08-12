import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';

/// V2 — Family First · hero + actions
/// Bet: this screen is really the family's home — Vera as the emotional hero,
/// caregivers right under her, everything else demoted to quiet pills.
class V2HeroActionsPage extends StatefulWidget {
  const V2HeroActionsPage({super.key});

  @override
  State<V2HeroActionsPage> createState() => _V2HeroActionsPageState();
}

class _V2HeroActionsPageState extends State<V2HeroActionsPage> {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            children: [
              // Baby hero — the emotional anchor
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: c.surfaceTertiary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.nightlight_round,
                    size: 44, color: c.textInverse.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 20),
              Text('Vera', style: t.headlineLarge),
              const SizedBox(height: 6),
              Text('7 months old',
                  style: t.bodyMedium?.copyWith(color: c.textTertiary)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.surfacePrimary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('Edit Vera\u2019s profile',
                      style:
                          t.labelMedium?.copyWith(color: c.textTertiary)),
                ),
              ),
              const SizedBox(height: 36),

              // Caregivers
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Caregiver(initials: 'PP', name: 'Paco', owner: true),
                  const SizedBox(width: 28),
                  _Caregiver(initials: 'SP', name: 'Sofie'),
                  const SizedBox(width: 28),
                  _InviteDot(),
                ],
              ),
              const SizedBox(height: 44),

              // Quiet utility pills
              _Pill(
                icon: Icons.person_outline_rounded,
                label: 'Your profile',
                sub: 'Paco · Father · Denmark',
              ),
              const SizedBox(height: 12),
              _Pill(
                icon: Icons.help_outline_rounded,
                label: 'Help & support',
                sub: 'FAQs · manuals · contact',
              ),
              const SizedBox(height: 12),
              _Pill(
                icon: Icons.sentiment_satisfied_alt_rounded,
                label: 'Enjoying Moonboon?',
                sub: 'Tell us in ten seconds',
              ),
              const SizedBox(height: 40),

              TextButton(
                onPressed: () {},
                child: Text('Log out',
                    style: t.labelMedium?.copyWith(color: c.textTertiary)),
              ),
              Text('Delete account',
                  style: t.labelSmall?.copyWith(
                      color: c.feedbackError.withValues(alpha: 0.85))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Caregiver extends StatelessWidget {
  final String initials;
  final String name;
  final bool owner;
  const _Caregiver(
      {required this.initials, required this.name, this.owner = false});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: c.surfacePrimary,
            shape: BoxShape.circle,
            border:
                Border.all(color: c.borderNormal.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: Text(initials,
              style: t.titleMedium?.copyWith(color: c.textTertiary)),
        ),
        const SizedBox(height: 8),
        Text(name, style: t.labelMedium),
        if (owner)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: c.surfaceTertiary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('Owner',
                  style: t.labelSmall
                      ?.copyWith(fontSize: 10, color: c.textTertiary)),
            ),
          ),
      ],
    );
  }
}

class _InviteDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: c.borderNormal),
          ),
          child: Icon(Icons.add_rounded, size: 22, color: c.textQuaternary),
        ),
        const SizedBox(height: 8),
        Text('Invite',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: c.textTertiary)),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _Pill({required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          color: c.surfacePrimary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: c.textQuaternary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: t.bodyMedium?.copyWith(color: c.textPrimary)),
                  Text(sub,
                      style: t.bodySmall?.copyWith(color: c.textTertiary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: c.textQuaternary),
          ],
        ),
      ),
    );
  }
}
