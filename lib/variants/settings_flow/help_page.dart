import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';
import 'flow_shared.dart';

/// H1 — Help hub · H2 — contact support (mail) · H3 — legacy-settings pointer.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return FlowScaffold(
      title: 'Help & support',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _link(context, Icons.help_outline_rounded, 'FAQs',
                'Answers to common questions'),
            const SizedBox(height: 10),
            _link(context, Icons.local_shipping_outlined, 'Order tracking',
                'Where is my delivery?'),
            const SizedBox(height: 10),
            _link(context, Icons.inventory_2_outlined, 'Shipping & returns',
                'Policies and how-tos'),
            const SizedBox(height: 10),
            _link(context, Icons.verified_outlined, 'Warranty & claims',
                'Something isn\u2019t right'),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.only(left: 22, bottom: 8),
              child: Text('USER MANUALS',
                  style: t.labelSmall?.copyWith(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: c.textQuaternary)),
            ),
            _link(context, Icons.menu_book_outlined, 'Swing motor',
                'Setup and care'),
            const SizedBox(height: 10),
            _link(context, Icons.menu_book_outlined, 'Baby monitor',
                'Setup and care'),
            const SizedBox(height: 28),
            PrimaryPill(
              label: 'Contact support',
              onTap: () => showFlowToast(
                  context, 'Opens mail to support@moonboon.com (mock)',
                  icon: Icons.mail_outline_rounded),
            ),
            const SizedBox(height: 28),
            // H3 — where legacy-setting seekers land softly
            Center(
              child: GestureDetector(
                onTap: () => showFlowToast(
                    context, 'Opens iOS Settings (mock)',
                    icon: Icons.settings_outlined),
                child: Text(
                  'Notifications and language are managed\nin your phone\u2019s settings.',
                  textAlign: TextAlign.center,
                  style: t.labelSmall?.copyWith(color: c.textQuaternary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _link(
      BuildContext context, IconData icon, String label, String sub) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => showFlowToast(context, 'Opens in browser (mock)',
          icon: Icons.open_in_new_rounded),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        decoration: BoxDecoration(
          color: c.surfacePrimary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.textQuaternary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: t.bodyMedium),
                  Text(sub,
                      style: t.bodySmall?.copyWith(color: c.textTertiary)),
                ],
              ),
            ),
            Icon(Icons.arrow_outward_rounded,
                size: 16, color: c.textQuaternary),
          ],
        ),
      ),
    );
  }
}
