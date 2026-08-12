import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/theme_colors.dart';
import '../settings_flow/flow_shared.dart';
import '../settings_flow/flow_state.dart';
import 'ref_baby_page.dart';
import 'ref_family_page.dart';
import 'ref_feedback_modal.dart';
import 'ref_profile_page.dart';
import 'ref_shared.dart';

/// V3 refinement — Settings overview (Figma 20:2517).
class RefOverviewPage extends StatefulWidget {
  /// Screenshot hook: 'logout' | 'delete' opens that confirm sheet
  /// right after the first frame.
  final String? autoOpen;
  const RefOverviewPage({super.key, this.autoOpen});

  @override
  State<RefOverviewPage> createState() => _RefOverviewPageState();
}

class _RefOverviewPageState extends State<RefOverviewPage> {
  final s = FlowState.i;

  @override
  void initState() {
    super.initState();
    if (widget.autoOpen != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        switch (widget.autoOpen) {
          case 'logout':
            _logOut();
          case 'delete':
            _deleteAccount();
        }
      });
    }
  }

  Future<void> _push(Widget page) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
  }

  Future<void> _logOut() async {
    final ok = await showRefConfirmSheet(
      context,
      title: 'Log out?',
      body: 'You can always sign back in with your email.',
      confirmLabel: 'Log out',
    );
    if (ok && mounted) showFlowToast(context, 'Logged out');
  }

  Future<void> _deleteAccount() async {
    final partner = s.members
        .where((m) => m.firstName != s.me.firstName)
        .firstOrNull;
    final baby = s.baby?.name ?? 'your baby';
    final ok = await showRefConfirmSheet(
      context,
      title: 'Delete your account?',
      body: partner != null
          ? 'This cannot be undone. ${partner.firstName} will become the '
              'family owner and keep caring for $baby.'
          : 'This cannot be undone. All your data will be permanently '
              'removed.',
      confirmLabel: 'Delete account',
      destructive: true,
    );
    if (ok && mounted) showFlowToast(context, 'Account deleted');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    final baby = s.baby;
    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      body: SafeArea(
        child: Column(
          children: [
            RefTopNav(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: LayoutBuilder(
                builder: (context, cons) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: cons.maxHeight - 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                    // — Baby header —
                    if (baby != null) ...[
                      GestureDetector(
                        onTap: () => _push(const RefBabyPage()),
                        child: RefPhoto(refBabyPhoto, size: 109),
                      ),
                      const SizedBox(height: 16),
                      Text(baby.name, style: t.headlineSmall),
                      const SizedBox(height: 6),
                      Text('${baby.age} old',
                          style:
                              t.bodyMedium?.copyWith(color: c.textTertiary)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _push(const RefBabyPage()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.surfaceTertiary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('Edit baby profile',
                              style: t.labelMedium
                                  ?.copyWith(color: c.textPrimary)),
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                    // — Family members —
                    Text('Family members',
                        style:
                            t.labelMedium?.copyWith(color: c.textTertiary)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final m in refMembers()) ...[
                          GestureDetector(
                            onTap: () => _push(const RefFamilyPage()),
                            child: RefPhoto(refPhotoFor(m), size: 62),
                          ),
                          const SizedBox(width: 12),
                        ],
                        GestureDetector(
                          onTap: () => _push(const RefFamilyPage()),
                          child: Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: c.brandTertiary),
                            ),
                            child: Icon(Icons.add_rounded,
                                size: 24, color: c.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // — Actions card —
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.surfacePrimary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _row('users', 'Your profile',
                              () => _push(const RefProfilePage())),
                          Divider(height: 12, color: c.borderSubdued),
                          _row('faq', 'FAQs', () {
                            showFlowToast(context, 'FAQs',
                                icon: Icons.help_outline_rounded);
                          }),
                          Divider(height: 12, color: c.borderSubdued),
                          _row('message_smile', 'Contact Support', () {
                            showFlowToast(context, 'Contact Support',
                                icon: Icons.chat_bubble_outline_rounded);
                          }),
                          Divider(height: 12, color: c.borderSubdued),
                          _row('hearts', 'Enjoying Moonboon?',
                              () => showRefFeedbackSheet(context)),
                        ],
                      ),
                    ),
                          ],
                        ),
                        // — Footer —
                        Column(
                          children: [
                            const SizedBox(height: 32),
                            _chip('Log out', c.surfaceTertiary,
                                c.textPrimary, _logOut),
                            const SizedBox(height: 14),
                            _chip('Delete account', c.feedbackError,
                                c.textInverse, _deleteAccount),
                            const SizedBox(height: 14),
                            Text('Moonboon 3.2.1',
                                style: t.labelSmall
                                    ?.copyWith(color: c.textQuaternary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String icon, String label, VoidCallback onTap) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 34,
        child: Row(
          children: [
            const SizedBox(width: 4),
            RefIcon(icon, size: 18, color: c.textTertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: t.labelMedium
                      ?.copyWith(fontSize: 16, color: c.textTertiary)),
            ),
            SvgPicture.asset(
              'assets/icons/utility/chevron_right.svg',
              width: 24,
              height: 24,
              colorFilter:
                  ColorFilter.mode(c.textTertiary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
      String label, Color bg, Color fg, VoidCallback onTap) {
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label, style: t.labelMedium?.copyWith(color: fg)),
      ),
    );
  }
}
