import 'package:flutter/material.dart';

import '../../common/modal_sheet.dart';
import '../../theme/theme_colors.dart';
import 'flow_shared.dart';
import 'flow_state.dart';

/// F-member — tap a caregiver on the constellation.
/// Owner viewing others: + Remove. Viewing yourself as non-owner: + Leave.
Future<void> showMemberSheet(BuildContext context, Caregiver member) async {
  final s = FlowState.i;
  final isMe = identical(member, s.me);
  final canRemove = s.iAmOwner && !isMe;
  final canLeave = isMe && !s.iAmOwner;
  final c = context.color;
  final t = Theme.of(context).textTheme;

  await ModalSheet.show<void>(
    context: context,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(
              initials: member.initials,
              size: 84,
              hasPhoto: member.hasPhoto),
          const SizedBox(height: 16),
          Text(member.name,
              style: t.headlineMedium?.copyWith(fontSize: 24, fontFamily: 'KeplerStd')),
          const SizedBox(height: 4),
          Text(member.role,
              style: t.bodyMedium?.copyWith(color: c.textTertiary)),
          const SizedBox(height: 12),
          if (member.owner)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: c.surfaceTertiary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('Family owner',
                  style: t.labelSmall?.copyWith(color: c.textTertiary)),
            ),
          const SizedBox(height: 8),
          Text('Member since ${member.memberSince}',
              style: t.labelSmall?.copyWith(color: c.textQuaternary)),
          if (canRemove || canLeave) ...[
            const SizedBox(height: 24),
            Builder(builder: (ctx) {
              return GestureDetector(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  if (canRemove) {
                    await _removeMember(context, member);
                  } else {
                    await _leaveFamily(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: c.surfacePrimary,
                    border: Border.all(
                        color: c.feedbackError.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    canRemove
                        ? 'Remove from family'
                        : 'Leave this family',
                    style: t.labelLarge?.copyWith(color: c.feedbackError),
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// F5 — remove member (owner), confirmation, destructive.
Future<void> _removeMember(BuildContext context, Caregiver member) async {
  final s = FlowState.i;
  final ok = await showConfirmSheet(
    context,
    title: 'Remove ${member.firstName}?',
    body:
        '${member.firstName} will lose access to ${s.baby!.name}\u2019s monitor and profile. You can invite them again anytime.',
    confirmLabel: 'Remove ${member.firstName}',
    destructive: true,
  );
  if (ok) {
    s.removeMember(member);
    if (context.mounted) {
      showFlowToast(context, '${member.firstName} removed');
    }
  }
}

/// F8 — leave family (non-owner, self-service).
Future<void> _leaveFamily(BuildContext context) async {
  final s = FlowState.i;
  final ok = await showConfirmSheet(
    context,
    title: 'Leave ${s.baby!.name}\u2019s family?',
    body:
        'You\u2019ll lose access to the monitor and ${s.baby!.name}\u2019s profile. The owner can invite you back anytime.',
    confirmLabel: 'Leave family',
    destructive: true,
  );
  if (ok) {
    s.scenario = FamilyScenario.empty;
    if (context.mounted) showFlowToast(context, 'You left the family');
  }
}
