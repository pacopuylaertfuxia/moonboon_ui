import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';

/// V5 — The Constellation · spatial map
/// Bet: a family is a structure, not a list — draw it. Vera at the center,
/// caregivers orbiting on hairline threads; utilities in a floating pill dock.
class V5ConstellationPage extends StatefulWidget {
  const V5ConstellationPage({super.key});

  @override
  State<V5ConstellationPage> createState() => _V5ConstellationPageState();
}

class _V5ConstellationPageState extends State<V5ConstellationPage> {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            Text('Vera\u2019s circle',
                style: t.headlineLarge?.copyWith(fontSize: 32)),
            const SizedBox(height: 6),
            Text('Everyone who cares for her',
                style: t.bodySmall?.copyWith(color: c.textTertiary)),
            Expanded(
              child: _Constellation(),
            ),
            // Floating utility dock
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DockItem(
                      icon: Icons.person_outline_rounded, label: 'Profile'),
                  _DockItem(icon: Icons.help_outline_rounded, label: 'Help'),
                  _DockItem(
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      label: 'Feedback'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Log out',
                style: t.labelMedium?.copyWith(color: c.textTertiary)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DockItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: c.textQuaternary),
            const SizedBox(height: 4),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: c.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _Constellation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, box) {
      final center = Offset(box.maxWidth / 2, box.maxHeight / 2 - 10);
      const orbit = 130.0;
      // Node angles (radians): Paco upper-left, Sofie upper-right,
      // invite lower-left so its thread stays clear of Vera's labels.
      final angles = [-2.35, -0.75, 2.55];
      final positions = [
        for (final a in angles)
          center + Offset(math.cos(a) * orbit, math.sin(a) * orbit),
      ];
      return Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ThreadsPainter(
                center: center,
                nodes: positions,
                color: c.borderNormal.withValues(alpha: 0.55),
              ),
            ),
          ),
          // Center: Vera
          Positioned(
            left: center.dx - 56,
            top: center.dy - 56,
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: c.surfaceTertiary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: c.overlayLevel1,
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.nightlight_round,
                      size: 34,
                      color: c.textInverse.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 8),
                Text('Vera', style: t.titleMedium?.copyWith(
                    fontFamily: 'KeplerStd', fontSize: 20)),
                Text('7 months',
                    style: t.labelSmall?.copyWith(color: c.textTertiary)),
              ],
            ),
          ),
          _node(context, positions[0], _PersonNode(
              initials: 'PP', name: 'Paco', owner: true)),
          _node(context, positions[1],
              _PersonNode(initials: 'SP', name: 'Sofie')),
          _node(context, positions[2], _InviteNode()),
        ],
      );
    });
  }

  Widget _node(BuildContext context, Offset at, Widget child) {
    return Positioned(
      left: at.dx - 44,
      top: at.dy - 34,
      child: SizedBox(width: 88, child: child),
    );
  }
}

class _ThreadsPainter extends CustomPainter {
  final Offset center;
  final List<Offset> nodes;
  final Color color;

  _ThreadsPainter(
      {required this.center, required this.nodes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (final n in nodes) {
      canvas.drawLine(center, n, paint);
    }
    // faint orbit ring
    canvas.drawCircle(
      center,
      130,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ThreadsPainter old) =>
      old.center != center || old.nodes != nodes || old.color != color;
}

class _PersonNode extends StatelessWidget {
  final String initials;
  final String name;
  final bool owner;
  const _PersonNode(
      {required this.initials, required this.name, this.owner = false});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: c.surfacePrimary,
            shape: BoxShape.circle,
            border:
                Border.all(color: c.borderNormal.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: Text(initials,
              style: t.labelLarge?.copyWith(color: c.textTertiary)),
        ),
        const SizedBox(height: 6),
        Text(name, style: t.labelMedium),
        if (owner)
          Container(
            margin: const EdgeInsets.only(top: 2),
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
      ],
    );
  }
}

class _InviteNode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.surfaceSecondary,
            border: Border.all(color: c.borderNormal),
          ),
          child: Icon(Icons.add_rounded, size: 22, color: c.textQuaternary),
        ),
        const SizedBox(height: 6),
        Text('Invite',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: c.textTertiary)),
      ],
    );
  }
}
