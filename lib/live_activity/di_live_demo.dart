import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'di_animation_demo.dart'; // DIStage, DIPillWidget, DIAudioBars, DIMonitorIcon

// ── Channel ───────────────────────────────────────────────────────────────────
const _channel = MethodChannel('com.moonboon/live_activity');

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBg      = Color(0xFF0D0D0D);
const _kSurface = Color(0xFF1A1A1A);
const _kClay    = Color(0xFFB59E85);
const _kCream   = Color(0xFFE5D5C5);
const _kGreen   = Color(0xFF34C759);
const _kRed     = Color(0xFFFF3B30);

// ── Sequence script ───────────────────────────────────────────────────────────
// (delayMs, stage, barLevel, statusLabel, alert, alertTitle, alertBody)
//  alert=true  → AlertConfiguration fires → real DI auto-expands for ~3s
//  ** iOS only auto-expands the DI when the app is BACKGROUNDED **
//  Press Start → go to home screen → watch the Dynamic Island.
//  statusLabel "Monitoring" → expanded shows "Active"
//  statusLabel "Sleeping"   → expanded shows "Quiet"
//  statusLabel "Crying"     → expanded shows "Crying"
const _kScript = [
  // 6 s window — go to home screen now
  (6000, DIStage.compact,    0.10, 'Monitoring', false, '', ''),
  // ① DI expands: "Active"
  (500,  DIStage.monitoring, 0.10, 'Monitoring', true,  'Baby Monitor', 'Monitoring is active'),
  // ② DI expands: "Quiet" (crossfade)
  (3500, DIStage.quiet,      0.10, 'Sleeping',   true,  'Baby Monitor', 'Baby is quiet'),
  // ③ collapses, stays quiet
  (4000, DIStage.compact,    0.10, 'Sleeping',   false, '', ''),
  // ④ bars intensify
  (2000, DIStage.compact,    0.85, 'Crying',     false, '', ''),
  // ⑤ DI expands: "Crying"
  (500,  DIStage.crying,     0.85, 'Crying',     true,  'Baby Monitor', 'Sound detected!'),
  // ⑥ re-alert after 3 s to keep DI expanded while baby is crying
  (3200, DIStage.crying,     0.85, 'Crying',     true,  'Baby Monitor', 'Still crying'),
  // ⑦ re-alert once more
  (3200, DIStage.crying,     0.85, 'Crying',     true,  'Baby Monitor', 'Still crying'),
  // reset
  (4000, DIStage.compact,    0.10, 'Sleeping',   false, '', ''),
];

// ─────────────────────────────────────────────────────────────────────────────

class DiLiveDemo extends StatefulWidget {
  const DiLiveDemo({super.key});

  @override
  State<DiLiveDemo> createState() => _DiLiveDemoState();
}

class _DiLiveDemoState extends State<DiLiveDemo> with TickerProviderStateMixin {
  late final AnimationController _barCtrl;

  DIStage _stage    = DIStage.compact;
  double  _barLevel = 0.10;
  bool    _running  = false;
  bool    _looping  = false;
  int     _stepIdx  = 0;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _looping = false;
    _running = false;
    _barCtrl.dispose();
    if (_running) _stopActivity();
    super.dispose();
  }

  // ── Live Activity control ─────────────────────────────────────────────────

  Future<void> _startActivity() async {
    try {
      await _channel.invokeMethod('start', {
        'variant': 8, // uses V8 DI — wide pill, explicit data
        'babyName': 'Baby',
        'soundLevel': _barLevel,
        'statusLabel': 'Sleeping',
        'battery': 87,
        'charging': false,
        'connection': 'connected',
        'wifi': 0.9,
        'motorRunning': false,
        'motorProgram': '',
        'monitorOn': true,
        'monitorMode': 'Standard',
        'elapsedSeconds': 0,
      });
    } catch (_) {}
  }

  Future<void> _pushUpdate(
    double soundLevel,
    String statusLabel,
    int elapsed, {
    bool alert = false,
    String alertTitle = '',
    String alertBody = '',
  }) async {
    try {
      await _channel.invokeMethod('update', {
        'soundLevel': soundLevel,
        'statusLabel': statusLabel,
        'battery': 87,
        'charging': false,
        'connection': 'connected',
        'wifi': 0.9,
        'elapsedSeconds': elapsed,
        if (alert) 'alert': true,
        if (alert && alertTitle.isNotEmpty) 'alertTitle': alertTitle,
        if (alert && alertBody.isNotEmpty)  'alertBody':  alertBody,
      });
    } catch (_) {}
  }

  Future<void> _stopActivity() async {
    try {
      await _channel.invokeMethod('endAll');
    } catch (_) {}
  }

  // ── Sequence loop ─────────────────────────────────────────────────────────

  Future<void> _startLoop() async {
    await _startActivity();
    _looping = true;
    int elapsed = 0;

    while (_looping && mounted) {
      for (int i = 0; i < _kScript.length; i++) {
        final (delay, stage, level, label, alert, aTitle, aBody) = _kScript[i];
        await Future.delayed(Duration(milliseconds: delay));
        if (!mounted || !_looping) return;
        elapsed += delay ~/ 1000;
        setState(() {
          _stage    = stage;
          _barLevel = level;
          _stepIdx  = i;
        });
        await _pushUpdate(
          level, label, elapsed,
          alert: alert,
          alertTitle: aTitle,
          alertBody: aBody,
        );
      }
    }
  }

  void _toggle() async {
    if (_running) {
      _looping = false;
      _running = false;
      await _stopActivity();
      setState(() {
        _stage    = DIStage.compact;
        _barLevel = 0.10;
        _stepIdx  = 0;
      });
    } else {
      _running = true;
      setState(() {});
      await _startLoop();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _stageLabel => switch (_stage) {
    DIStage.compact    => _barLevel > 0.5
        ? 'compact · loud — alert fires next, DI will expand'
        : 'compact · quiet — background the app to see auto-expansion',
    DIStage.monitoring => '① alert fired → DI expands "Active"',
    DIStage.quiet      => '② alert fired → DI expands "Quiet"',
    DIStage.crying     => '⑤–⑦ alert re-fires every 3s → DI stays expanded "Crying"',
  };

  Color get _dotColor => _stage == DIStage.crying
      ? _kRed
      : _running ? _kGreen : Colors.white24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Nav ───────────────────────────────────────────────────────────
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
                    'Dynamic Island — Live',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Flutter pill simulation ────────────────────────────────────────
            Center(
              child: DIPillWidget(
                stage: _stage,
                barLevel: _barLevel,
                barCtrl: _barCtrl,
              ),
            ),

            const SizedBox(height: 24),

            // ── DI hint ───────────────────────────────────────────────────────
            if (_running)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Background the app — DI expands automatically on each update',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // ── Stage label ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _running ? _stageLabel : 'Tap Start to run the sequence',
                  key: ValueKey(_stageLabel + _running.toString()),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Sequence diagram ──────────────────────────────────────────────
            _SequenceDiagram(activeIdx: _running ? _stepIdx : -1),

            const SizedBox(height: 32),

            // ── Start / Stop button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 52,
                  decoration: BoxDecoration(
                    color: _running ? const Color(0xFF2C1A1A) : _kSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _running ? _kRed.withAlpha(100) : _kClay.withAlpha(60),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _running ? 'Stop' : 'Start',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _running ? _kRed : _kCream,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Sequence diagram ──────────────────────────────────────────────────────────

class _SequenceDiagram extends StatelessWidget {
  const _SequenceDiagram({required this.activeIdx});
  final int activeIdx;

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('…', 'Wait\n6s', false),
      ('①', 'Expanded\nActive', true),
      ('②', 'Expanded\nQuiet', true),
      ('③', 'Compact\nQuiet', false),
      ('④', 'Compact\nLoud', false),
      ('⑤', 'Expanded\nCrying', true),
      ('⑥', 'Crying\n+3s', true),
      ('⑦', 'Crying\n+3s', true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(steps.length, (i) {
          final (num, label, expanded) = steps[i];
          final isActive = i == activeIdx;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: expanded ? 32 : 18,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _kClay
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  num,
                  style: TextStyle(
                    color: isActive ? _kCream : Colors.white24,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? Colors.white38 : Colors.white12,
                    fontSize: 8,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
