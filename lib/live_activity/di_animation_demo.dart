import 'dart:math' as math;

import 'package:flutter/material.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBg     = Color(0xFF0D0D0D);
const _kClay   = Color(0xFFB59E85);
const _kCream  = Color(0xFFE5D5C5);
const _kBorder = Color(0xFF262626);

// ── Pill geometry (device points, calibrated to iPhone 15 Pro DI) ─────────────
const _kCompactW  = 126.0;
const _kExpandedW = 262.0;
const _kPillH     = 37.0;
const _kPillR     = 20.0;
const _kPadH      =  9.0;
const _kIconW     = 22.0;
// 6 bars × 4pt + 5 gaps × 2.5pt = 36.5 ≈ 37pt
const _kBarsW     = 37.0;

// ── States (public so di_live_demo.dart can import them) ─────────────────────
enum DIStage { compact, monitoring, quiet, crying }

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class DiAnimationDemo extends StatefulWidget {
  const DiAnimationDemo({super.key});

  @override
  State<DiAnimationDemo> createState() => _DiAnimationDemoState();
}

class _DiAnimationDemoState extends State<DiAnimationDemo>
    with TickerProviderStateMixin {

  late final AnimationController _barCtrl;

  DIStage _stage    = DIStage.compact;
  double _barLevel = 0.15;
  bool   _looping  = false;

  // (delay ms, stage, barLevel)
  static const _script = [
    (1000, DIStage.monitoring, 0.15),
    (2800, DIStage.quiet,      0.15),
    (2200, DIStage.compact,    0.15),
    (3000, DIStage.compact,    0.85), // bars intensify, still compact
    (1200, DIStage.crying,     0.85),
    (3200, DIStage.compact,    0.15), // reset
  ];

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
    _startLoop();
  }

  Future<void> _startLoop() async {
    _looping = true;
    while (_looping && mounted) {
      for (final (delay, stage, level) in _script) {
        await Future.delayed(Duration(milliseconds: delay));
        if (!mounted || !_looping) return;
        setState(() {
          _stage    = stage;
          _barLevel = level;
        });
      }
    }
  }

  @override
  void dispose() {
    _looping = false;
    _barCtrl.dispose();
    super.dispose();
  }

  String get _stageLabel => switch (_stage) {
    DIStage.compact    => _barLevel > 0.5
        ? '5 — compact · bars intensify'
        : '1 / 4 — compact · quiet bars',
    DIStage.monitoring => '2 — expanded · Monitoring',
    DIStage.quiet      => '3 — expanded · Quiet',
    DIStage.crying     => '6 — expanded · Crying',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Nav bar ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white38, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Dynamic Island Demo',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ── Fake status bar area (simulates top of phone) ─────────────────
            const SizedBox(height: 8),
            Center(
              child: DIPillWidget(
                stage: _stage,
                barLevel: _barLevel,
                barCtrl: _barCtrl,
              ),
            ),

            // ── Phone frame context ───────────────────────────────────────────
            const Spacer(),

            // ── State label ───────────────────────────────────────────────────
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _stageLabel,
                  key: ValueKey(_stageLabel),
                  style: const TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Sequence diagram ──────────────────────────────────────────────
            const _SequenceDiagram(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic Island Widget
// ─────────────────────────────────────────────────────────────────────────────

class DIPillWidget extends StatelessWidget {
  const DIPillWidget({
    required this.stage,
    required this.barLevel,
    required this.barCtrl,
  });

  final DIStage             stage;
  final double             barLevel;
  final AnimationController barCtrl;

  bool   get _isExpanded => stage != DIStage.compact;
  String get _text => switch (stage) {
    DIStage.monitoring => 'Monitoring',
    DIStage.quiet      => 'Quiet',
    DIStage.crying     => 'Crying',
    DIStage.compact    => '',
  };

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _isExpanded ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      builder: (context, t, _) {
        final pillW = _kCompactW + (_kExpandedW - _kCompactW) * t;

        // Bars x-position: slides from far-right (compact) to just-after-icon (expanded)
        final barsXCompact  = _kCompactW - _kPadH - _kBarsW;
        final barsXExpanded = _kPadH + _kIconW + 7;
        final barsX         = barsXCompact + (barsXExpanded - barsXCompact) * t;

        return Container(
          width: pillW,
          height: _kPillH,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(_kPillR),
            border: Border.all(color: _kBorder, width: 1.5),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── Monitor icon — fixed left ─────────────────────────────────
              Positioned(
                left: _kPadH,
                top: 0, bottom: 0,
                child: const Center(child: DIMonitorIcon()),
              ),

              // ── Audio bars — slide left as pill expands ───────────────────
              Positioned(
                left: barsX,
                top: 0, bottom: 0,
                child: Center(
                  child: DIAudioBars(level: barLevel, ctrl: barCtrl),
                ),
              ),

              // ── Status text — fades in as pill expands ────────────────────
              if (t > 0.02)
                Positioned(
                  right: _kPadH,
                  top: 0, bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _easeIn(t),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          _text,
                          key: ValueKey(_text),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: _kCream,
                            letterSpacing: -0.3,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Cubic ease-in curve (no Curves dependency needed)
  double _easeIn(double t) => t * t * t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Monitor icon
// ─────────────────────────────────────────────────────────────────────────────

class DIMonitorIcon extends StatelessWidget {
  const DIMonitorIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kIconW,
      height: _kIconW,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/monitor_nobg.png',
          width: 14,
          height: 14,
          color: Colors.white,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.monitor,
            size: 12,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Audio bars
// ─────────────────────────────────────────────────────────────────────────────

class DIAudioBars extends StatelessWidget {
  const DIAudioBars({required this.level, required this.ctrl});

  final double              level;
  final AnimationController ctrl;

  // (frequency multiplier, phase offset) per bar — gives organic asymmetric wave
  static const _cfg = [
    (1.00, 0.00),
    (1.45, 0.90),
    (0.60, 1.75),
    (1.70, 0.35),
    (0.85, 2.20),
    (1.25, 1.10),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = ctrl.value * 2 * math.pi;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_cfg.length, (i) {
            final (freq, phase) = _cfg[i];
            // sin oscillates 0→1→0; min height 2pt, max driven by level
            final sinVal = 0.5 + 0.5 * math.sin(t * freq + phase);
            final h = (2.0 + level * 11.0 * sinVal).clamp(2.0, 14.0);
            return Container(
              margin: EdgeInsets.only(right: i < _cfg.length - 1 ? 2.5 : 0),
              width: 4,
              height: h,
              decoration: BoxDecoration(
                color: _kClay,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sequence diagram (visual reference at bottom)
// ─────────────────────────────────────────────────────────────────────────────

class _SequenceDiagram extends StatelessWidget {
  const _SequenceDiagram();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('①', 'Compact\nQuiet', false),
      ('②', 'Expanded\nMonitoring', true),
      ('③', 'Expanded\nQuiet', true),
      ('④', 'Compact\nQuiet', false),
      ('⑤', 'Compact\nCrying', false),
      ('⑥', 'Expanded\nCrying', true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: steps.map((s) {
          final (num, label, expanded) = s;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: expanded ? 30 : 18,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                num,
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white12,
                  fontSize: 8,
                  height: 1.4,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
