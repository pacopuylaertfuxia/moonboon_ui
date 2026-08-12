import 'package:flutter/material.dart';

import '../../common/modal_sheet.dart';
import '../../theme/theme_colors.dart';
import 'flow_shared.dart';
import 'flow_state.dart';

/// F4 — Invite sheet (owner): QR + share link. Links are live tokens,
/// no pending state — generating a new one revokes the old.
Future<void> showInviteSheet(BuildContext context, String babyName) async {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  await ModalSheet.show<void>(
    context: context,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Invite to $babyName\u2019s family',
              textAlign: TextAlign.center,
              style: t.headlineMedium?.copyWith(fontSize: 24, fontFamily: 'KeplerStd')),
          const SizedBox(height: 8),
          Text('Let them scan this code, or send the link.',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: c.textTertiary)),
          const SizedBox(height: 24),
          const MockQr(size: 190),
          const SizedBox(height: 24),
          Builder(builder: (ctx) {
            return PrimaryPill(
              label: 'Share invite link',
              onTap: () {
                Navigator.of(ctx).pop();
                showFlowToast(context, 'Share sheet opens (mock)',
                    icon: Icons.ios_share_rounded);
              },
            );
          }),
          const SizedBox(height: 12),
          Text(
            'The link works until you create a new one.',
            style: t.labelSmall?.copyWith(color: c.textQuaternary),
          ),
          const SizedBox(height: 4),
        ],
      ),
    ),
  );
}

/// F-accept — what the invitee sees after opening the link (happy path).
Future<void> showJoinSheet(BuildContext context) async {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  await ModalSheet.show<void>(
    context: context,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Avatar(initials: 'V', size: 84, hasPhoto: true),
          const SizedBox(height: 18),
          Text('Join Vera\u2019s family?',
              style: t.headlineMedium?.copyWith(fontSize: 24, fontFamily: 'KeplerStd')),
          const SizedBox(height: 8),
          Text('Paco invited you to care for Vera together.',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: c.textTertiary)),
          const SizedBox(height: 24),
          Builder(builder: (ctx) {
            return PrimaryPill(
              label: 'Join family',
              onTap: () {
                Navigator.of(ctx).pop();
                FlowState.i.scenario = FamilyScenario.full;
                FlowState.i.viewer = Viewer.member;
                showFlowToast(context, 'Welcome to the family');
              },
            );
          }),
          const SizedBox(height: 8),
          Builder(builder: (ctx) {
            return TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Not now',
                  style: t.labelMedium?.copyWith(color: c.textTertiary)),
            );
          }),
        ],
      ),
    ),
  );
}

/// F7 — Request access: scan the owner's QR in person, or type the code.
/// Same token as the invite — no owner-side approval needed.
class RequestAccessPage extends StatefulWidget {
  const RequestAccessPage({super.key});

  @override
  State<RequestAccessPage> createState() => _RequestAccessPageState();
}

class _RequestAccessPageState extends State<RequestAccessPage> {
  final _code = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return FlowScaffold(
      title: 'Join a family',
      subtitle: 'Ask the family owner to show you their invite code.',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          children: [
            // Mock camera viewfinder
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.surfaceSubdued,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: c.borderNormal.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded,
                      size: 44, color: c.textQuaternary),
                  const SizedBox(height: 12),
                  Text('Point at their QR code',
                      style:
                          t.bodySmall?.copyWith(color: c.textTertiary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('or enter the code',
                style: t.labelSmall?.copyWith(color: c.textQuaternary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: c.surfacePrimary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextField(
                controller: _code,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                style: t.titleMedium?.copyWith(letterSpacing: 4),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'MOON-0000',
                  hintStyle: t.titleMedium?.copyWith(
                      letterSpacing: 4, color: c.textInactive),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const Spacer(),
            PrimaryPill(
              label: 'Join',
              onTap: () async {
                await showJoinSheet(context);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
