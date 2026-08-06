import 'package:flutter/material.dart';

import '../../common/modal_sheet.dart';
import '../../theme/theme_colors.dart';

/// Creme sub-page scaffold: circular back button + Kepler serif title.
class FlowScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Future<bool> Function()? onWillPop;

  const FlowScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.onWillPop,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return PopScope(
      canPop: onWillPop == null,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await onWillPop!() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: c.surfaceSecondary,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: CircleBackButton(onTap: () async {
                  if (onWillPop == null || await onWillPop!()) {
                    if (context.mounted) Navigator.of(context).pop();
                  }
                }),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.headlineLarge?.copyWith(fontSize: 30)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(subtitle!,
                          style: t.bodySmall?.copyWith(color: c.textTertiary)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const CircleBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration:
            BoxDecoration(color: c.surfacePrimary, shape: BoxShape.circle),
        child: Icon(Icons.arrow_back_rounded, size: 20, color: c.textPrimary),
      ),
    );
  }
}

/// White pill text field, app-style.
class PillField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const PillField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 22, bottom: 6),
          child: Text(label,
              style: t.labelSmall?.copyWith(color: c.textTertiary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: c.surfacePrimary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: t.bodyMedium,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-width apricot pill CTA.
class PrimaryPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PrimaryPill({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: c.surfaceTertiary,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: t.titleMedium?.copyWith(color: c.textPrimary)),
      ),
    );
  }
}

/// Floating white pill toast — "Saved" pattern.
void showFlowToast(BuildContext context, String message,
    {IconData icon = Icons.check_rounded}) {
  final overlay = Overlay.of(context);
  final c = context.color;
  final t = Theme.of(context).textTheme;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: MediaQuery.of(context).viewPadding.top + 12,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: c.surfacePrimary,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: c.overlayLevel1,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: c.feedbackSuccess),
                const SizedBox(width: 8),
                Text(message, style: t.labelMedium),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1800), () => entry.remove());
}

/// Confirmation sheet — today's pattern: serif question, primary pill,
/// quiet cancel. Destructive actions use the error token, never a big red fill.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  final result = await ModalSheet.show<bool>(
    context: context,
    child: Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: t.headlineMedium?.copyWith(fontSize: 24, fontFamily: 'KeplerStd')),
            const SizedBox(height: 12),
            Text(body,
                textAlign: TextAlign.center,
                style: t.bodyMedium?.copyWith(color: c.textTertiary)),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: destructive
                      ? c.surfacePrimary
                      : c.surfaceTertiary,
                  border: destructive
                      ? Border.all(
                          color: c.feedbackError.withValues(alpha: 0.6))
                      : null,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  confirmLabel,
                  style: t.titleMedium?.copyWith(
                      color:
                          destructive ? c.feedbackError : c.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel',
                  style: t.labelMedium?.copyWith(color: c.textTertiary)),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Generic sheet in the same visual family as [showConfirmSheet].
Future<void> showConfirmSheetLike(
  BuildContext context,
  Widget Function(BuildContext ctx, VoidCallback pop) builder,
) async {
  await ModalSheet.show<void>(
    context: context,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Builder(
        builder: (ctx) => builder(ctx, () => Navigator.of(ctx).pop()),
      ),
    ),
  );
}

/// Photo source sheet (Camera / Library) + mock crop acknowledgment.
/// Returns true if a photo was "picked".
Future<bool> showPhotoSheet(BuildContext context, {bool allowRemove = false}) async {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  final result = await ModalSheet.show<String>(
    context: context,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Add a photo',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 24)),
          const SizedBox(height: 20),
          _photoOption(context, Icons.photo_camera_outlined, 'Take a photo',
              'camera'),
          const SizedBox(height: 10),
          _photoOption(context, Icons.photo_library_outlined,
              'Choose from library', 'library'),
          if (allowRemove) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).pop('remove'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text('Remove photo',
                    style: t.labelMedium?.copyWith(
                        color: c.feedbackError.withValues(alpha: 0.85))),
              ),
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    ),
  );
  if (result == 'remove') return false;
  return result != null;
}

Widget _photoOption(
    BuildContext context, IconData icon, String label, String value) {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  return GestureDetector(
    onTap: () => Navigator.of(context).pop(value),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: c.textQuaternary),
          const SizedBox(width: 14),
          Text(label, style: t.bodyMedium),
        ],
      ),
    ),
  );
}

/// Caregiver avatar: photo placeholder = initials on apricot (first-class).
class Avatar extends StatelessWidget {
  final String initials;
  final double size;
  final bool hasPhoto;
  const Avatar(
      {super.key,
      required this.initials,
      this.size = 62,
      this.hasPhoto = false});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    if (hasPhoto) {
      return ClipOval(
        child: Image.asset(
          'assets/images/streaming_bg.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.surfaceTertiary.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: t.titleMedium?.copyWith(
          fontSize: size * 0.3,
          color: c.textTertiary,
        ),
      ),
    );
  }
}

/// Deterministic fake QR code (prototype only).
class MockQr extends StatelessWidget {
  final double size;
  const MockQr({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomPaint(painter: _QrPainter(c.textPrimary)),
    );
  }
}

class _QrPainter extends CustomPainter {
  final Color color;
  _QrPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const n = 17;
    final cell = size.width / n;
    final paint = Paint()..color = color;
    int seed = 42;
    bool bit() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return (seed >> 16) % 3 == 0;
    }

    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        final inFinder = (x < 5 && y < 5) ||
            (x >= n - 5 && y < 5) ||
            (x < 5 && y >= n - 5);
        if (inFinder) continue;
        if (bit()) {
          canvas.drawRect(
              Rect.fromLTWH(x * cell, y * cell, cell * 0.92, cell * 0.92),
              paint);
        }
      }
    }
    // Finder squares
    void finder(double fx, double fy) {
      canvas.drawRect(
          Rect.fromLTWH(fx, fy, cell * 5, cell * 5),
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.9);
      canvas.drawRect(
          Rect.fromLTWH(fx + cell * 1.6, fy + cell * 1.6, cell * 1.8,
              cell * 1.8),
          paint);
    }

    finder(0, 0);
    finder(size.width - cell * 5, 0);
    finder(0, size.height - cell * 5);
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.color != color;
}
