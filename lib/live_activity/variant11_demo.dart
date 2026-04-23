import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.moonboon/live_activity');

const _kBlack   = Color(0xFF000000);
const _kClay    = Color(0xFFB59E85);
const _kOlive   = Color(0xFF70695F);
const _kApricot = Color(0xFFE5D5C5);
const _kCream   = Color(0xFFF5F3F1);

class Variant11Demo extends StatefulWidget {
  const Variant11Demo({super.key});
  @override
  State<Variant11Demo> createState() => _Variant11DemoState();
}

class _Variant11DemoState extends State<Variant11Demo> {
  bool   _running = false;
  double _level   = 0.08;
  String _status  = 'Sleeping';

  Future<void> _startActivity() async {
    try {
      await _channel.invokeMethod('start', {
        'variant': 11,
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

  Future<void> _stop() async {
    try { await _channel.invokeMethod('endAll'); } catch (_) {}
  }

  void _toggle() async {
    if (_running) {
      await _stop();
      setState(() { _running = false; _level = 0.08; _status = 'Sleeping'; });
    } else {
      setState(() => _running = true);
      await _startActivity();
    }
  }

  Future<void> _setCrying(bool crying) async {
    final level  = crying ? 1.0 : 0.08;
    final label  = crying ? 'Crying' : 'Sleeping';
    setState(() { _level = level; _status = label; });
    try {
      await _channel.invokeMethod('update', {
        'soundLevel': level,
        'statusLabel': label,
        'battery': 87,
        'charging': false,
        'connection': 'connected',
        'wifi': 0.9,
        'elapsedSeconds': 0,
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
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
                  child: const Icon(Icons.arrow_back_ios_new, color: _kClay, size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Variant 11 — Lock Screen Pill',
                    style: TextStyle(color: _kOlive, fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ]),
            ),

            const SizedBox(height: 24),

            // Lock screen preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _LockScreenPreview(level: _level, status: _status),
            ),

            const SizedBox(height: 32),

            // State controls (only when running)
            if (_running) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Lock your phone to see the Live Activity',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _kClay, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(children: [
                  Expanded(
                    child: _StateButton(
                      label: 'Sleeping',
                      active: _status == 'Sleeping',
                      onTap: () => _setCrying(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StateButton(
                      label: 'Crying',
                      active: _status == 'Crying',
                      onTap: () => _setCrying(true),
                    ),
                  ),
                ]),
              ),
            ],

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 52,
                  decoration: BoxDecoration(
                    color: _running ? _kOlive : _kApricot,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _running ? 'Stop' : 'Start Live Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _running ? _kApricot : _kOlive,
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

// ── Lock screen preview ────────────────────────────────────────────────────────

class _LockScreenPreview extends StatelessWidget {
  const _LockScreenPreview({required this.level, required this.status});
  final double level;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: _kApricot,
        borderRadius: BorderRadius.circular(1000),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 50,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          // Camera rings
          const _CameraRings(),
          const SizedBox(width: 14),
          // moonboon + waveform
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'moonboon',
                  style: TextStyle(
                    fontFamily: 'KeplerStd',
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                    color: _kBlack,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                _WaveformStrip(level: level),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Baby face
          Image.asset(
            'assets/images/baby.png',
            width: 46,
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(width: 46, height: 44),
          ),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}

// ── Camera rings ───────────────────────────────────────────────────────────────

class _CameraRings extends StatelessWidget {
  const _CameraRings();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kClay.withAlpha(46), width: 1),
            ),
          ),
          // Middle ring
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kClay.withAlpha(82), width: 1),
            ),
          ),
          // Inner ring
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kClay.withAlpha(128), width: 1),
            ),
          ),
          // Camera lens
          ClipOval(
            child: Image.asset(
              'assets/images/monitor.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40,
                height: 40,
                color: _kBlack.withAlpha(210),
              ),
            ),
          ),
          // Live dot
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: _kApricot, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Waveform strip ─────────────────────────────────────────────────────────────

class _WaveformStrip extends StatelessWidget {
  const _WaveformStrip({required this.level});
  final double level;

  static const _pattern = [
    3.0, 5.0, 3.0, 7.0, 3.0, 5.0, 9.0, 5.0, 3.0, 7.0,
    3.0, 5.0, 3.0, 9.0, 5.0, 3.0, 7.0, 5.0, 3.0, 5.0,
    7.0, 3.0, 5.0, 9.0, 3.0, 5.0, 7.0, 3.0, 5.0, 3.0,
    7.0, 5.0, 9.0, 3.0, 5.0, 7.0, 3.0, 5.0, 3.0, 5.0,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_pattern.length, (i) {
          final h = (_pattern[i] * (0.5 + level)).clamp(2.0, 14.0);
          return Padding(
            padding: const EdgeInsets.only(right: 1.5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 2,
              height: h,
              decoration: BoxDecoration(
                color: _kClay.withAlpha((179 + (level * 76).toInt()).clamp(0, 255)),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── State toggle button ────────────────────────────────────────────────────────

class _StateButton extends StatelessWidget {
  const _StateButton({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 40,
        decoration: BoxDecoration(
          color: active ? _kClay : _kApricot,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: active ? _kCream : _kOlive,
            ),
          ),
        ),
      ),
    );
  }
}
