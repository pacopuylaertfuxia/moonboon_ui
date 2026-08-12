import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/modal_sheet.dart';
import '../../theme/theme_colors.dart';
import '../settings_flow/flow_shared.dart';
import '../settings_flow/flow_state.dart';
import 'ref_shared.dart';

/// V3 refinement — Family orbit + invite (Figma 59:13176 / 68:4293).
class RefFamilyPage extends StatefulWidget {
  /// Screenshot hook: 'member' | 'remove' | 'invite' opens that sheet
  /// right after the first frame.
  final String? autoOpen;
  const RefFamilyPage({super.key, this.autoOpen});

  @override
  State<RefFamilyPage> createState() => _RefFamilyPageState();
}

class _RefFamilyPageState extends State<RefFamilyPage>
    with SingleTickerProviderStateMixin {
  final s = FlowState.i;

  @override
  void initState() {
    super.initState();
    if (widget.autoOpen != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final kasper = refMembers().last;
        switch (widget.autoOpen) {
          case 'member':
            _openMember(kasper);
          case 'remove':
            _confirmRemove(kasper);
          case 'invite':
            _openQr();
        }
      });
    }
  }

  /// One slow lap of the family around the baby.
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  )..repeat();

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  void _shareInvite() {
    showFlowToast(context, 'Invite link copied', icon: Icons.link_rounded);
  }

  /// Refined Invite sheet (68:4398): serif title, round QR, caption.
  void _openQr() {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    ModalSheet.show<void>(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Invite',
                style: t.headlineSmall?.copyWith(fontSize: 28)),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.surfacePrimary,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/settings_ref/qr.png',
                  width: 138,
                  height: 138,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Ask your family member to scan this QR code to get access '
              'to the app or share a link with them',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: c.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  /// Member sheet (68:4153): name · role · photo · Remove from family.
  Future<void> _openMember(Caregiver m) async {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    final remove = await ModalSheet.show<bool>(
      context: context,
      child: Builder(
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(m.firstName,
                textAlign: TextAlign.center,
                style: t.headlineSmall?.copyWith(fontSize: 28)),
            const SizedBox(height: 8),
            Text(m.role,
                textAlign: TextAlign.center,
                style: t.bodyMedium?.copyWith(color: c.textTertiary)),
            const SizedBox(height: 22),
            Center(child: RefPhoto(refPhotoFor(m), size: 158)),
            const SizedBox(height: 22),
            _SheetPill(
              icon: Icons.delete_outline_rounded,
              label: 'Remove from family',
              onTap: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ),
    );
    if (remove == true && mounted) await _confirmRemove(m);
  }

  /// Confirm sheet (68:4245): "Remove {name}?" · body · photo · buttons.
  Future<void> _confirmRemove(Caregiver m) async {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    final baby = s.baby?.name ?? 'the baby';
    final ok = await ModalSheet.show<bool>(
      context: context,
      child: Builder(
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Remove ${m.firstName}?',
                textAlign: TextAlign.center,
                style: t.headlineSmall?.copyWith(fontSize: 28)),
            const SizedBox(height: 10),
            Text(
              "${m.firstName} will lose access to $baby's monitor and "
              'profile. You can invite them again anytime.',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: c.textTertiary),
            ),
            const SizedBox(height: 22),
            Center(child: RefPhoto(refPhotoFor(m), size: 158)),
            const SizedBox(height: 22),
            _SheetPill(
              icon: Icons.delete_outline_rounded,
              label: 'Remove ${m.firstName}',
              onTap: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel',
                  style:
                      t.labelMedium?.copyWith(color: c.textTertiary)),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) {
      setState(() => refMembers().remove(m));
      showFlowToast(context, '${m.firstName} removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    final baby = s.baby;
    final members = refMembers();
    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      body: SafeArea(
        child: Column(
          children: [
            RefTopNav(title: baby != null ? "${baby.name}'s" : 'Your'),
            Text('family',
                style: t.bodyMedium?.copyWith(color: c.textTertiary)),
            Expanded(
              child: Center(
                child: _Orbit(
                  members: members,
                  turns: _orbit,
                  onTapMember: _openMember,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: GestureDetector(
                onTap: _shareInvite,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: c.surfaceTertiary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: Text('Share invite link',
                      style: t.titleMedium?.copyWith(color: c.textPrimary)),
                ),
              ),
            ),
            GestureDetector(
              onTap: _openQr,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Open family QR code',
                    style:
                        t.titleMedium?.copyWith(color: c.brandPrimary)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Apricot pill button used in the family sheets.
class _SheetPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetPill(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: c.surfaceTertiary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: c.textPrimary),
            const SizedBox(width: 8),
            Text(label,
                style: t.titleMedium?.copyWith(color: c.textPrimary)),
          ],
        ),
      ),
    );
  }
}

/// Baby in the middle; the family slowly orbits around them on a 242px ring.
class _Orbit extends StatelessWidget {
  final List<Caregiver> members;
  final Animation<double> turns;
  final ValueChanged<Caregiver> onTapMember;
  const _Orbit({
    required this.members,
    required this.turns,
    required this.onTapMember,
  });

  // Angles measured from the refined Figma (59:13177):
  // owner bottom-right, partner top, third member left.
  static const _angles = [48.4, -68.5, 160.0];

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    const ring = 242.0;
    const box = 340.0;
    return SizedBox(
      width: box,
      height: box,
      child: AnimatedBuilder(
        animation: turns,
        builder: (context, _) {
          final spin = turns.value * 360;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: ring,
                height: ring,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.brandTertiary),
                ),
              ),
              RefPhoto(refBabyPhoto, size: 109),
              for (var i = 0;
                  i < members.length && i < _angles.length;
                  i++)
                _onRing(
                  _angles[i] + spin,
                  ring / 2,
                  GestureDetector(
                    onTap: () => onTapMember(members[i]),
                    child: RefPhoto(refPhotoFor(members[i]), size: 62),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _onRing(double deg, double radius, Widget child) {
    final rad = deg * math.pi / 180;
    return Transform.translate(
      offset: Offset(radius * math.cos(rad), radius * math.sin(rad)),
      child: child,
    );
  }
}
