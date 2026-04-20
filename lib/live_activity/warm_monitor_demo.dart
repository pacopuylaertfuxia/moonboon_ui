import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.moonboon/live_activity');

// ── Palette (mirrors Figma warm design) ───────────────────────────────────────
const _kCreme  = Color(0xFFF1E8DE);
const _kApricot = Color(0xFFE5D5C5);
const _kClay   = Color(0xFFB59E85);
const _kOlive  = Color(0xFF70695F);

// ── Sequence ──────────────────────────────────────────────────────────────────
// (delayMs, soundLevel, statusLabel, alert, alertTitle, alertBody)
const _kScript = [
  (5000, 0.10, 'Monitoring', false, '', ''),
  (500,  0.10, 'Monitoring', true,  'Baby Monitor', 'Monitoring is active'),
  (3000, 0.10, 'Sleeping',   true,  'Baby Monitor', 'Baby is quiet'),
  (4000, 0.10, 'Sleeping',   false, '', ''),
  (2000, 0.85, 'Crying',     false, '', ''),
  (500,  0.85, 'Crying',     true,  'Baby Monitor', 'Sound detected!'),
  (3200, 0.85, 'Crying',     true,  'Baby Monitor', 'Still crying'),
  (3200, 0.85, 'Crying',     true,  'Baby Monitor', 'Still crying'),
  (4000, 0.10, 'Sleeping',   false, '', ''),
];

// ─────────────────────────────────────────────────────────────────────────────

class WarmMonitorDemo extends StatefulWidget {
  const WarmMonitorDemo({super.key});
  @override
  State<WarmMonitorDemo> createState() => _WarmMonitorDemoState();
}

class _WarmMonitorDemoState extends State<WarmMonitorDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barCtrl;

  bool   _running  = false;
  bool   _looping  = false;
  double _level    = 0.10;
  String _status   = 'Sleeping';
  int    _stepIdx  = 0;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _looping = false;
    _barCtrl.dispose();
    super.dispose();
  }

  // ── Live Activity ──────────────────────────────────────────────────────────

  Future<void> _startActivity() async {
    try {
      await _channel.invokeMethod('start', {
        'variant': 9,
        'babyName': 'Baby',
        'soundLevel': _level,
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

  Future<void> _update(
    double level,
    String label,
    int elapsed, {
    bool alert = false,
    String alertTitle = '',
    String alertBody = '',
  }) async {
    try {
      await _channel.invokeMethod('update', {
        'soundLevel': level,
        'statusLabel': label,
        'battery': 87,
        'charging': false,
        'connection': 'connected',
        'wifi': 0.9,
        'monitorMode': 'Standard',
        'elapsedSeconds': elapsed,
        if (alert) 'alert': true,
        if (alert && alertTitle.isNotEmpty) 'alertTitle': alertTitle,
        if (alert && alertBody.isNotEmpty)  'alertBody':  alertBody,
      });
    } catch (_) {}
  }

  Future<void> _stop() async {
    try { await _channel.invokeMethod('endAll'); } catch (_) {}
  }

  // ── Sequence loop ──────────────────────────────────────────────────────────

  Future<void> _startLoop() async {
    await _startActivity();
    _looping = true;
    int elapsed = 0;

    while (_looping && mounted) {
      for (int i = 0; i < _kScript.length; i++) {
        final (delay, level, label, alert, aTitle, aBody) = _kScript[i];
        await Future.delayed(Duration(milliseconds: delay));
        if (!mounted || !_looping) return;
        elapsed += delay ~/ 1000;
        setState(() {
          _level   = level;
          _status  = label;
          _stepIdx = i;
        });
        await _update(level, label, elapsed,
            alert: alert, alertTitle: aTitle, alertBody: aBody);
      }
    }
  }

  void _toggle() async {
    if (_running) {
      _looping = false;
      _running = false;
      await _stop();
      setState(() { _level = 0.10; _status = 'Sleeping'; _stepIdx = 0; });
    } else {
      _running = true;
      setState(() {});
      await _startLoop();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCreme,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Color(0xFFB59E85), size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Warm Monitor — Live Activity',
                  style: TextStyle(color: _kOlive, fontSize: 14),
                ),
              ]),
            ),

            const SizedBox(height: 8),

            // Flutter preview of lock screen design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WarmLockScreenPreview(
                level: _level,
                status: _status,
                running: _running,
                barCtrl: _barCtrl,
              ),
            ),

            const SizedBox(height: 20),

            if (_running)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Background the app — the Dynamic Island auto-expands on each update',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _kClay, fontSize: 12),
                ),
              ),

            const Spacer(),

            // Sequence steps
            _StepDiagram(activeIdx: _running ? _stepIdx : -1),

            const SizedBox(height: 28),

            // Start / Stop
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 52,
                  decoration: BoxDecoration(
                    color: _running
                        ? _kOlive.withAlpha(230)
                        : _kApricot,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _running ? 'Stop' : 'Start',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _running ? _kCreme : _kOlive,
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

// ── Lock screen preview (Flutter mockup) ──────────────────────────────────────

class _WarmLockScreenPreview extends StatelessWidget {
  const _WarmLockScreenPreview({
    required this.level,
    required this.status,
    required this.running,
    required this.barCtrl,
  });

  final double level;
  final String status;
  final bool running;
  final AnimationController barCtrl;

  String get _displayStatus => switch (status) {
    'Sleeping'   => 'Quiet',
    'Monitoring' => 'Active',
    'Crying'     => 'Crying',
    _            => status,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCreme,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kClay.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: _kClay.withAlpha(30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status + waveform row
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _kApricot.withAlpha(140),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status',
                        style: TextStyle(fontSize: 11, color: _kClay)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _displayStatus,
                        key: ValueKey(_displayStatus),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _kOlive,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(child: _MiniWaveform(level: level, ctrl: barCtrl)),
              ],
            ),
          ),

          // Baby photo placeholder
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 120,
            decoration: BoxDecoration(
              color: _kApricot.withAlpha(100),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.child_care, size: 48, color: _kClay),
            ),
          ),

          const SizedBox(height: 10),

          // Bottom stat cards
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: [
                // Sounds card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _kApricot.withAlpha(140),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level > 0.5 ? 'Sounds' : 'Sound',
                              style: const TextStyle(fontSize: 11, color: _kClay),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                level > 0.5 ? 'Detected' : 'Quiet',
                                key: ValueKey(level > 0.5),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _kOlive,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          running ? '1' : '—',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _kOlive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Mode card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _kApricot.withAlpha(140),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mode',
                                style: TextStyle(fontSize: 11, color: _kClay)),
                            Text('Standard',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _kOlive,
                                )),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _kApricot,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              size: 16, color: _kOlive),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini animated waveform bars ───────────────────────────────────────────────

class _MiniWaveform extends StatelessWidget {
  const _MiniWaveform({required this.level, required this.ctrl});
  final double level;
  final AnimationController ctrl;

  static const _pattern = [0.3, 0.6, 0.3, 0.9, 0.3, 0.5, 1.0, 0.5, 0.3, 0.7,
                            0.3, 0.5, 0.3, 1.0, 0.5, 0.3, 0.7, 0.5, 0.3, 0.5,
                            0.7, 0.3, 0.5, 1.0, 0.3, 0.5, 0.7, 0.3, 0.5, 0.3];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_pattern.length, (i) {
            final jitter = (i % 3 == 0 ? ctrl.value : (ctrl.value + 0.33) % 1.0);
            final h = 3.0 + _pattern[i] * (0.4 + level * 0.6) * 14 * (0.8 + jitter * 0.4);
            return Container(
              width: 2,
              height: h,
              decoration: BoxDecoration(
                color: _kClay.withAlpha(160),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Step diagram ──────────────────────────────────────────────────────────────

class _StepDiagram extends StatelessWidget {
  const _StepDiagram({required this.activeIdx});
  final int activeIdx;

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('…', 'Wait\n5s',      false),
      ('①', 'Active',        true),
      ('②', 'Quiet',         true),
      ('③', 'Compact\nQuiet',false),
      ('④', 'Loud',          false),
      ('⑤', 'Crying',        true),
      ('⑥', '+3s',           true),
      ('⑦', '+3s',           true),
      ('⑧', 'Reset',         false),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(steps.length, (i) {
          final (num, label, expanded) = steps[i];
          final active = i == activeIdx;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: expanded ? 28 : 16,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? _kClay : _kApricot,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 4),
              Text(num,
                  style: TextStyle(
                    color: active ? _kOlive : _kClay.withAlpha(120),
                    fontSize: 9,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  )),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? _kOlive.withAlpha(180) : _kClay.withAlpha(80),
                    fontSize: 7,
                    height: 1.3,
                  )),
            ],
          );
        }),
      ),
    );
  }
}
