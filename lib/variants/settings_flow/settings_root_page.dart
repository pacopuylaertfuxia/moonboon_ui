import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';
import 'baby_form_page.dart';
import 'flow_shared.dart';
import 'flow_state.dart';
import 'help_page.dart';
import 'invite_flows.dart';
import 'member_sheet.dart';
import 'profile_page.dart';

/// Settings root — V2 Family First. The root IS the family:
/// album-card hero (V4 steal), caregiver constellation, quiet utility pills.
/// States: R1a owner · R1b member · R2 empty · R3 solo.
class SettingsRootPage extends StatefulWidget {
  const SettingsRootPage({super.key});

  @override
  State<SettingsRootPage> createState() => _SettingsRootPageState();
}

class _SettingsRootPageState extends State<SettingsRootPage> {
  FlowState get s => FlowState.i;

  void _refresh() => setState(() {});

  Future<void> _push(Widget page) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings',
                      style: t.headlineLarge?.copyWith(fontSize: 34)),
                  const SizedBox(height: 20),
                  if (s.hasFamily) ...[
                    _BabyHeroCard(
                      baby: s.baby!,
                      onManage: () => _push(BabyFormPage(
                          mode: BabyFormMode.edit, baby: s.baby!)),
                    ),
                    const SizedBox(height: 24),
                    _constellation(),
                  ] else
                    _emptyState(),
                  const SizedBox(height: 36),
                  _Pill(
                    icon: Icons.person_outline_rounded,
                    label: 'Your profile',
                    sub: '${s.me.firstName} · ${s.me.role} · ${s.me.country}',
                    onTap: () => _push(const ProfilePage()),
                  ),
                  const SizedBox(height: 12),
                  _Pill(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & support',
                    sub: 'FAQs · manuals · contact',
                    onTap: () => _push(const HelpPage()),
                  ),
                  const SizedBox(height: 12),
                  _Pill(
                    icon: Icons.sentiment_satisfied_alt_rounded,
                    label: 'Enjoying Moonboon?',
                    sub: 'Tell us in ten seconds',
                    onTap: () => showFeedbackSheet(context),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _logOut,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('Log out',
                                style: t.labelMedium
                                    ?.copyWith(color: c.textTertiary)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _deleteAccount,
                          child: Text('Delete account',
                              style: t.labelSmall?.copyWith(
                                  color: c.feedbackError
                                      .withValues(alpha: 0.85))),
                        ),
                        const SizedBox(height: 20),
                        Text('Moonboon 3.2.1',
                            style: t.labelSmall?.copyWith(
                                fontSize: 10, color: c.textQuaternary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _debugCorner(),
          ],
        ),
      ),
    );
  }

  // ---- family ----

  Widget _constellation() {
    final members = s.members;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final m in members) ...[
            _CaregiverDot(
              caregiver: m,
              isMe: identical(m, s.me),
              onTap: () async {
                await showMemberSheet(context, m);
                _refresh();
              },
            ),
            const SizedBox(width: 26),
          ],
          if (s.iAmOwner)
            _InviteDot(onTap: () => showInviteSheet(context, s.baby!.name)),
        ],
      ),
    );
  }

  Widget _emptyState() {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: c.surfaceTertiary.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.nightlight_round,
                size: 30, color: c.textTertiary),
          ),
          const SizedBox(height: 20),
          Text('Your family lives here',
              style: t.headlineMedium?.copyWith(fontSize: 24, fontFamily: 'KeplerStd')),
          const SizedBox(height: 8),
          Text(
            'Add your baby to get started, or join a\nfamily that already exists.',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: 24),
          PrimaryPill(
            label: 'Add a baby',
            onTap: () =>
                _push(const BabyFormPage(mode: BabyFormMode.create)),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _push(const RequestAccessPage()),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Request access',
                  style: t.labelMedium?.copyWith(color: c.textTertiary)),
            ),
          ),
        ],
      ),
    );
  }

  // ---- account ----

  Future<void> _logOut() async {
    final ok = await showConfirmSheet(
      context,
      title: 'Log out?',
      body: 'You can always sign back in with your email.',
      confirmLabel: 'Log out',
    );
    if (ok && mounted) showFlowToast(context, 'Logged out (mock)');
  }

  Future<void> _deleteAccount() async {
    final String body;
    if (s.hasFamily && s.iAmOwner && s.members.length > 1) {
      final next =
          s.members.firstWhere((m) => !identical(m, s.me)).firstName;
      body =
          'This cannot be undone. $next will become the family owner and keep caring for ${s.baby!.name}.';
    } else if (s.hasFamily && s.iAmOwner) {
      body =
          'This cannot be undone. Your family and ${s.baby!.name}\u2019s profile will be removed with it.';
    } else {
      body = 'This cannot be undone. Your profile and data will be removed.';
    }
    final ok = await showConfirmSheet(
      context,
      title: 'Delete your account?',
      body: body,
      confirmLabel: 'Delete account',
      destructive: true,
    );
    if (ok && mounted) showFlowToast(context, 'Account deleted (mock)');
  }

  // ---- debug corner (demo only) ----

  Widget _debugCorner() {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    Widget chip(String label, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.surfacePrimary.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(label,
                style: t.labelSmall
                    ?.copyWith(fontSize: 10, color: c.textQuaternary)),
          ),
        );
    return Positioned(
      top: 8,
      right: 16,
      child: Row(
        children: [
          chip(s.viewer == Viewer.owner ? 'as Paco' : 'as Sofie', () {
            setState(() => s.viewer =
                s.viewer == Viewer.owner ? Viewer.member : Viewer.owner);
          }),
          const SizedBox(width: 6),
          chip(s.scenario.name, () {
            setState(() => s.scenario = FamilyScenario.values[
                (s.scenario.index + 1) % FamilyScenario.values.length]);
          }),
        ],
      ),
    );
  }
}

/// V4-steal: album card as the Vera hero.
class _BabyHeroCard extends StatelessWidget {
  final Baby baby;
  final VoidCallback onManage;
  const _BabyHeroCard({required this.baby, required this.onManage});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            width: double.infinity,
            child: baby.hasPhoto
                ? Image.asset('assets/images/streaming_bg.png',
                    fit: BoxFit.cover)
                : Container(
                    color: c.surfaceTertiary,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.nightlight_round,
                            size: 44,
                            color: c.textInverse.withValues(alpha: 0.65)),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: c.surfacePrimary
                                  .withValues(alpha: 0.9),
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
          ),
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
                      Text('YOUR FAMILY',
                          style: t.labelSmall?.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: c.textQuaternary,
                          )),
                      const SizedBox(height: 4),
                      Text('${baby.name} · ${baby.age}',
                          style: t.titleMedium?.copyWith(
                              fontFamily: 'KeplerStd',
                              fontSize: 22,
                              color: c.textPrimary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onManage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: c.surfaceTertiary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        Text('Manage',
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

class _CaregiverDot extends StatelessWidget {
  final Caregiver caregiver;
  final bool isMe;
  final VoidCallback onTap;
  const _CaregiverDot(
      {required this.caregiver, required this.isMe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Avatar(
              initials: caregiver.initials,
              hasPhoto: caregiver.hasPhoto,
              size: 62),
          const SizedBox(height: 8),
          Text(isMe ? 'You' : caregiver.firstName, style: t.labelMedium),
          if (caregiver.owner)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
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
      ),
    );
  }
}

class _InviteDot extends StatelessWidget {
  final VoidCallback onTap;
  const _InviteDot({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.borderNormal),
            ),
            child:
                Icon(Icons.add_rounded, size: 22, color: c.textQuaternary),
          ),
          const SizedBox(height: 8),
          Text('Invite',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: context.color.textTertiary)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  const _Pill(
      {required this.icon,
      required this.label,
      required this.sub,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
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
                  Text(label,
                      style: t.bodyMedium?.copyWith(color: c.textPrimary)),
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

/// B1 — "Enjoying Moonboon?" sheet. Logic mirrors today's app, unchanged.
Future<void> showFeedbackSheet(BuildContext context) async {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  await showConfirmSheetLike(context, (ctx, pop) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Enjoying Moonboon?',
            style: t.headlineMedium?.copyWith(fontSize: 24, fontFamily: 'KeplerStd')),
        const SizedBox(height: 12),
        Text('Your answer helps other parents find us.',
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: c.textTertiary)),
        const SizedBox(height: 28),
        PrimaryPill(
            label: 'Yes, loving it',
            onTap: () {
              pop();
              showFlowToast(context, 'Opens App Store review (mock)');
            }),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            pop();
            showFlowToast(context, 'Opens feedback form (mock)',
                icon: Icons.edit_outlined);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Not really',
                style: t.labelMedium?.copyWith(color: c.textTertiary)),
          ),
        ),
      ],
    );
  });
}
