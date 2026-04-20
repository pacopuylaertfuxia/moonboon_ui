import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.moonboon/live_activity');

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBlack   = Color(0xFF000000);
const _kClay    = Color(0xFFB59E85);
const _kOlive   = Color(0xFF70695F);
const _kApricot = Color(0xFFE5D5C5);
const _kCream   = Color(0xFFF5F3F1);

// ── Sequence script ───────────────────────────────────────────────────────────
const _kScript = [
  (6000, 0.08, 'Sleeping', false, '',             ''),
  (500,  0.08, 'Sleeping', true,  'Baby Monitor', 'Monitoring is active'),
  (3500, 0.08, 'Sleeping', true,  'Baby Monitor', 'Baby is quiet'),
  (4000, 0.08, 'Sleeping', false, '',             ''),
  (2000, 1.00, 'Crying',   false, '',             ''),
  (500,  1.00, 'Crying',   true,  'Baby Monitor', 'Sound detected!'),
  (3200, 1.00, 'Crying',   true,  'Baby Monitor', 'Still crying'),
  (3200, 1.00, 'Crying',   true,  'Baby Monitor', 'Still crying'),
  (4000, 0.08, 'Sleeping', false, '',             ''),
];

class Variant10Demo extends StatefulWidget {
  const Variant10Demo({super.key});
  @override
  State<Variant10Demo> createState() => _Variant10DemoState();
}

class _Variant10DemoState extends State<Variant10Demo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barCtrl;

  bool   _running  = false;
  bool   _looping  = false;
  double _level    = 0.08;
  String _status   = 'Sleeping';
  int    _stepIdx  = 0;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _looping = false;
    _barCtrl.dispose();
    super.dispose();
  }

  Future<void> _startActivity() async {
    try {
      await _channel.invokeMethod('start', {
        'variant': 10,
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

  Future<void> _update(double level, String label, int elapsed,
      {bool alert = false, String alertTitle = '', String alertBody = ''}) async {
    try {
      await _channel.invokeMethod('update', {
        'soundLevel': level,
        'statusLabel': label,
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

  Future<void> _stop() async {
    try { await _channel.invokeMethod('endAll'); } catch (_) {}
  }

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
        setState(() { _level = level; _status = label; _stepIdx = i; });
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
      setState(() { _level = 0.08; _status = 'Sleeping'; _stepIdx = 0; });
    } else {
      _running = true;
      setState(() {});
      await _startLoop();
    }
  }

  bool get _isCrying => _status == 'Crying';
  String get _displayStatus => _isCrying ? 'Crying' : 'Quiet';

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
                const Text('Variant 10',
                    style: TextStyle(color: _kOlive, fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ]),
            ),

            const SizedBox(height: 16),

            // Expanded DI preview (dark)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ExpandedPreview(
                status: _displayStatus,
                isCrying: _isCrying,
                level: _level,
                barCtrl: _barCtrl,
              ),
            ),

            const SizedBox(height: 12),

            // Lock screen preview (warm)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _LockScreenPreview(
                status: _displayStatus,
                isCrying: _isCrying,
                level: _level,
                barCtrl: _barCtrl,
              ),
            ),

            const SizedBox(height: 20),

            if (_running)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Background the app — DI auto-expands on each alert',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _kClay, fontSize: 12),
                ),
              ),

            const Spacer(),

            _StepDiagram(activeIdx: _running ? _stepIdx : -1),
            const SizedBox(height: 28),

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
                      _running ? 'Stop' : 'Start',
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

// ── Moon logo ─────────────────────────────────────────────────────────────────

class _MoonLogo extends StatelessWidget {
  const _MoonLogo({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.nightlight_round, color: color, size: size),
    );
  }
}

// ── Baby photo ────────────────────────────────────────────────────────────────

class _BabyPhoto extends StatelessWidget {
  const _BabyPhoto({required this.isCrying, required this.size, this.onDark = false});
  final bool isCrying;
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.242),
      child: Image.asset(
        isCrying ? 'assets/images/crying.png' : 'assets/images/quiet.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: onDark ? Colors.grey.shade700 : const Color(0xFFD9D9D9),
        ),
      ),
    );
  }
}

// ── Expanded DI preview (dark) ────────────────────────────────────────────────

class _ExpandedPreview extends StatelessWidget {
  const _ExpandedPreview({
    required this.status,
    required this.isCrying,
    required this.level,
    required this.barCtrl,
  });
  final String status;
  final bool isCrying;
  final double level;
  final AnimationController barCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 147,
      decoration: BoxDecoration(
        color: _kBlack,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 28),

          // Moon above text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MoonLogo(size: 22, color: Colors.white),
              const SizedBox(height: 9),
              const Text('Baby is',
                  style: TextStyle(fontSize: 16, color: _kApricot,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  status,
                  key: ValueKey(status),
                  style: const TextStyle(
                    fontSize: 34,
                    color: _kClay,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),

          // Bars centred
          const Spacer(),
          _FourBars(level: level, ctrl: barCtrl),
          const Spacer(),

          // Baby photo
          _BabyPhoto(isCrying: isCrying, size: 105, onDark: true),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

// ── Lock screen preview (warm) ────────────────────────────────────────────────

class _LockScreenPreview extends StatelessWidget {
  const _LockScreenPreview({
    required this.status,
    required this.isCrying,
    required this.level,
    required this.barCtrl,
  });
  final String status;
  final bool isCrying;
  final double level;
  final AnimationController barCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 147,
      decoration: BoxDecoration(
        color: _kApricot,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 28),

          // Moon above text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MoonLogo(size: 22, color: _kOlive),
              const SizedBox(height: 9),
              const Text('Baby is',
                  style: TextStyle(fontSize: 16, color: _kOlive,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  status,
                  key: ValueKey(status),
                  style: const TextStyle(
                    fontSize: 34,
                    color: Color(0xFF464545),
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Bars — centred
          _FourBars(level: level, ctrl: barCtrl),

          const Spacer(),

          // Baby photo — bigger
          _BabyPhoto(isCrying: isCrying, size: 120),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

// ── 4 animated gradient bars ──────────────────────────────────────────────────

class _FourBars extends AnimatedWidget {
  const _FourBars({
    required this.level,
    required AnimationController ctrl,
  }) : super(listenable: ctrl);

  final double level;

  static const _peakH = [7.0, 13.0, 17.0, 9.0];
  static const _minH  = 5.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final h = _minH + (_peakH[i] - _minH) * level;
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 5,
            height: h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kClay, _kOlive],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        );
      }),
    );
  }
}

// ── Sequence step diagram ─────────────────────────────────────────────────────

class _StepDiagram extends StatelessWidget {
  const _StepDiagram({required this.activeIdx});
  final int activeIdx;

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('…', 'Wait\n6s',    false),
      ('①', 'Active',      true),
      ('②', 'Quiet',       true),
      ('③', 'Quiet\n—',    false),
      ('④', 'Loud',        false),
      ('⑤', 'Crying',      true),
      ('⑥', '+3s',         true),
      ('⑦', '+3s',         true),
      ('⑧', 'Reset',       false),
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
                width: expanded ? 28 : 14,
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
                    fontSize: 7, height: 1.3,
                  )),
            ],
          );
        }),
      ),
    );
  }
}
