import 'package:flutter/material.dart';

import '../../common/modal_sheet.dart';
import '../../theme/theme_colors.dart';
import '../settings_flow/flow_shared.dart';
import 'ref_shared.dart';

/// V3 refinement — "Enjoying moonboon?" sheet (Figma 40:10214).
Future<void> showRefFeedbackSheet(BuildContext context) async {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  final answer = await ModalSheet.show<String>(
    context: context,
    child: Builder(
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Enjoying moonboon?', style: t.headlineSmall),
          const SizedBox(height: 10),
          Text('Your feedback helps us improve.',
              style: t.bodyMedium?.copyWith(color: c.textTertiary)),
          const SizedBox(height: 24),
          Row(
            children: [
              _cell(ctx, 'face_smile', 'Yes'),
              const SizedBox(width: 8),
              _cell(ctx, 'face_neutral', 'Meh'),
              const SizedBox(width: 8),
              _cell(ctx, 'face_frown', 'No'),
            ],
          ),
        ],
      ),
    ),
  );
  if (answer != null && context.mounted) {
    showFlowToast(context, 'Thanks for your feedback',
        icon: Icons.favorite_rounded);
  }
}

Widget _cell(BuildContext ctx, String icon, String label) {
  final c = ctx.color;
  final t = Theme.of(ctx).textTheme;
  return Expanded(
    child: GestureDetector(
      onTap: () => Navigator.of(ctx).pop(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: c.surfacePrimary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                color: c.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: RefIcon(icon, size: 23, color: c.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(label, style: t.bodyMedium?.copyWith(color: c.textPrimary)),
          ],
        ),
      ),
    ),
  );
}
