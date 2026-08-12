import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di_animation_demo.dart';
import 'live_activity_cubit.dart';
import 'live_activity_service.dart';
import 'live_activity_state.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBg      = Color(0xFF0D0D0D);
const _kSurface = Color(0xFF1A1A1A);
const _kCard    = Color(0xFF222222);
const _kClay    = Color(0xFFB59E85);
const _kCream   = Color(0xFFE5D5C5);
const _kGreen   = Color(0xFF34C759);
const _kRed     = Color(0xFFFF3B30);

// ── Sequence script ───────────────────────────────────────────────────────────
// Press Start → background the app → watch the real Dynamic Island.
// The activity uses Monitor A (variant 1):
//   compact  = monitor icon flush-left + green dot + audio bars
//   expanded = baby photo left · "Crying" right
// After the initial cry alert fires, _startLoop re-alerts every 3s for 30s
// so the DI stays expanded continuously (iOS collapses after ~8s otherwise).
const _kScript = [
  // 5s window — background the app now
  (5000, DIStage.compact, 0.10, 'Sleeping', false, '', ''),
  // ① bars ramp up — sound detected
  (5000, DIStage.compact, 0.82, 'Crying',   false, '', ''),
  // ② DI expands "Crying" — initial alert + audio starts
  //    _startLoop then runs a 10×3s re-alert sub-loop (30s hold)
  (500,  DIStage.crying,  0.82, 'Crying',   true,  'Baby Monitor', 'Sound detected!'),
  // ③ reset to quiet
  (4000, DIStage.compact, 0.10, 'Sleeping', false, '', ''),
];

// ─────────────────────────────────────────────────────────────────────────────

class PrototypeConversionPage extends StatelessWidget {
  const PrototypeConversionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveActivityCubit(LiveActivityService()),
      child: const _PrototypeConversionPageContent(),
    );
  }
}

class _PrototypeConversionPageContent extends StatefulWidget {
  const _PrototypeConversionPageContent();

  @override
  State<_PrototypeConversionPageContent> createState() =>
      _PrototypeConversionPageState();
}

class _PrototypeConversionPageState extends State<_PrototypeConversionPageContent>
    with TickerProviderStateMixin {

  late final AnimationController _barCtrl;
  late final AnimationController _shimmerCtrl;
  late LiveActivityCubit _cubit;

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
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<LiveActivityCubit>();
  }

  @override
  void dispose() {
    _looping = false;
    _running = false;
    _barCtrl.dispose();
    _shimmerCtrl.dispose();
    _cubit.endAll();
    super.dispose();
  }

  // ── Sequence loop ─────────────────────────────────────────────────────────

  Future<void> _startLoop() async {
    // Start the real Live Activity (Monitor A — variant 1, with image rotation)
    await _cubit.startMonitorA();
    _looping = true;
    int elapsed = 0;

    while (_looping && mounted) {
      for (int i = 0; i < _kScript.length; i++) {
        final (delay, stage, level, label, alert, aTitle, aBody) = _kScript[i];
        if (delay > 0) {
          await Future.delayed(Duration(milliseconds: delay));
        }
        if (!mounted || !_looping) return;
        elapsed += delay ~/ 1000;

        setState(() {
          _stage    = stage;
          _barLevel = level;
          _stepIdx  = i;
        });

        // Push sound level first (fast path — no image load)
        await _cubit.setSoundLevel(level);

        if (alert) {
          await _cubit.triggerAlert(statusLabel: label, alertBody: aBody);
          await _cubit.playCrySound();
          // Keep the DI expanded: iOS collapses after ~8s without a fresh alert.
          // Re-fire every 3s for 30s (10 iterations).
          for (int k = 0; k < 10 && _looping && mounted; k++) {
            await Future.delayed(const Duration(seconds: 3));
            if (!mounted || !_looping) return;
            await _cubit.triggerAlert(statusLabel: label, alertBody: 'Still crying');
          }
        } else if (!alert && label == 'Sleeping') {
          await _cubit.stopCrySound();
        }
      }
    }
  }

  void _toggle() async {
    if (_running) {
      _looping = false;
      _running = false;
      await _cubit.endAll();
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

  // ── UI helpers ────────────────────────────────────────────────────────────

  String get _stageLabel => switch (_stage) {
    DIStage.compact => _barLevel > 0.5
        ? 'Sound detected — DI will expand "Crying"'
        : 'Quiet · background the app to watch the Dynamic Island',
    DIStage.crying  => 'DI expanded "Crying" · re-alerting every 3s for 30s',
    _               => 'Monitoring',
  };

  Color get _dotColor => _stage == DIStage.crying
      ? _kRed
      : _running ? _kGreen : Colors.white24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: BlocBuilder<LiveActivityCubit, LiveActivityState>(
        builder: (ctx, state) {
          return Column(
            children: [
              // ── Baby feed (cycling B&W images — simulates live stream) ───────
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _BabyImageFeed(),
                    // Waveform overlay when sound detected
                    Positioned(
                      left: 0, right: 0, bottom: 0,
                      child: AnimatedOpacity(
                        opacity: state.soundLevel > 0.15 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: _WaveformOverlay(level: state.soundLevel, shimmer: _shimmerCtrl),
                      ),
                    ),
                    // Nav bar overlay
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white60, size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Prototype Conversion',
                                style: TextStyle(color: Colors.white60, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Controls ──────────────────────────────────────────────────
              Expanded(
                flex: 4,
                child: Container(
                  color: _kSurface,
                  child: Column(
                    children: [
                      // Flutter DI pill preview
                      const SizedBox(height: 16),
                      _ProtoPillWidget(
                        stage: _stage,
                        barLevel: _barLevel,
                        barCtrl: _barCtrl,
                      ),
                      const SizedBox(height: 12),

                      // Status dot + hint
                      if (_running)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                color: _dotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'Background the app — DI expands automatically',
                                style: TextStyle(color: Colors.white38, fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),

                      const Spacer(),

                      // Stage label
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _running ? _stageLabel : 'Tap Start · then background the app',
                            key: ValueKey(_stageLabel + _running.toString()),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white24, fontSize: 11),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sequence diagram
                      _SequenceDiagram(activeIdx: _running ? _stepIdx : -1),

                      const SizedBox(height: 24),

                      // Audio sim toggle (only when running)
                      if (_running && state.monitorActive) ...[
                        GestureDetector(
                          onTap: _cubit.toggleAudioSimulation,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: state.isSimulatingAudio
                                  ? _kGreen.withValues(alpha: 0.15)
                                  : _kCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: state.isSimulatingAudio
                                    ? _kGreen.withValues(alpha: 0.4)
                                    : Colors.white12,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                state.isSimulatingAudio
                                    ? 'Simulating audio — sine wave oscillator'
                                    : 'Simulate audio',
                                style: TextStyle(
                                  color: state.isSimulatingAudio ? _kGreen : Colors.white38,
                                  fontSize: 12,
                                  fontWeight: state.isSimulatingAudio
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Start / Stop button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: GestureDetector(
                          onTap: _toggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 52,
                            decoration: BoxDecoration(
                              color: _running
                                  ? const Color(0xFF2C1A1A)
                                  : _kSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _running
                                    ? _kRed.withValues(alpha: 0.4)
                                    : _kClay.withValues(alpha: 0.25),
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

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Flutter pill preview — Monitor A visual ───────────────────────────────────
// Compact: [monitor icon + green dot] [audio bars]
// Expanded: [icon] [audio bars] [status text]

class _ProtoPillWidget extends StatelessWidget {
  const _ProtoPillWidget({
    required this.stage,
    required this.barLevel,
    required this.barCtrl,
  });

  final DIStage             stage;
  final double              barLevel;
  final AnimationController barCtrl;

  bool   get _isExpanded => stage != DIStage.compact;
  String get _text => switch (stage) {
    DIStage.monitoring => 'Active',
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
        const compactW  = 126.0;
        const expandedW = 262.0;
        const pillH     = 37.0;
        const pillR     = 20.0;
        const padH      = 5.0;   // tighter left pad — icon flush to margin
        const iconW     = 22.0;
        const barsW     = 37.0;

        final pillW = compactW + (expandedW - compactW) * t;
        final barsXCompact  = compactW - padH - barsW;
        final barsXExpanded = padH + iconW + 7;
        final barsX         = barsXCompact + (barsXExpanded - barsXCompact) * t;

        return Container(
          width: pillW,
          height: pillH,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(pillR),
            border: Border.all(color: const Color(0xFF262626), width: 1.5),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Monitor icon + green dot — flush left
              Positioned(
                left: padH,
                top: 0, bottom: 0,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: iconW, height: iconW,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1C1C1E),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/monitor_nobg.png',
                            width: 13, height: 13,
                            color: Colors.white,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.monitor, size: 12, color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      // Green live dot
                      Positioned(
                        top: -2, right: -2,
                        child: Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            color: _kGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Audio bars — slide toward icon when expanded
              Positioned(
                left: barsX,
                top: 0, bottom: 0,
                child: Center(
                  child: DIAudioBars(level: barLevel, ctrl: barCtrl),
                ),
              ),

              // Status text — fades in when expanded
              if (t > 0.02)
                Positioned(
                  right: padH,
                  top: 0, bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: (t * t * t).clamp(0.0, 1.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          _text,
                          key: ValueKey(_text),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFE5D5C5),
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
}

// ── Cycling B&W baby images (simulates live camera stream) ────────────────

class _BabyImageFeed extends StatefulWidget {
  const _BabyImageFeed();
  @override
  State<_BabyImageFeed> createState() => _BabyImageFeedState();
}

class _BabyImageFeedState extends State<_BabyImageFeed> {
  static const _paths = [
    'assets/images/monitor_1.png',
    'assets/images/monitor_2.png',
    'assets/images/monitor_3.png',
  ];

  int    _idx   = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _idx = (_idx + 1) % _paths.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: SizedBox.expand(
        key: ValueKey(_idx),
        child: Image.asset(
          _paths[_idx],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0D0D0D)),
        ),
      ),
    );
  }
}

// ── Waveform overlay on video ──────────────────────────────────────────────

class _WaveformOverlay extends StatelessWidget {
  final double level;
  final AnimationController shimmer;
  const _WaveformOverlay({required this.level, required this.shimmer});

  static const _personalities = [
    0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.4, 1.0, 0.5, 0.7,
    0.8, 0.4, 0.9, 0.6, 0.5, 0.7, 1.0, 0.4, 0.8, 0.6,
    0.5, 0.9, 0.7, 0.4,
  ];

  static const _n = 24;

  // Highlight sweeps left→right as phase goes 0→1.
  // Returns 0.0–1.0: how much shimmer applies to bar i.
  double _shimmerFor(int i, double phase) {
    final t = i / (_n - 1);
    // Wrap-aware distance so the pulse loops seamlessly
    final dist = (t - phase).abs();
    final wrapped = dist < 0.5 ? dist : 1.0 - dist;
    // Beam width ≈ 20% of total — sharp centre, soft edges
    return (1.0 - wrapped / 0.18).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (context, _) {
        final phase = shimmer.value;
        return Container(
          height: 52,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xCC0F0D0B), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_n, (i) {
              final w = _personalities[i];
              final h = (2.0 + w * 4.0 + level * w * 28.0).clamp(2.0, 34.0);

              final s = _shimmerFor(i, phase);
              // At high sound levels shimmer fades out — bars are vivid anyway
              final shimmerStrength = s * (1.0 - level * 0.7).clamp(0.0, 1.0);

              final baseAlpha  = 0.30 + level * 0.55;
              final finalAlpha = (baseAlpha + shimmerStrength * 0.50).clamp(0.0, 1.0);
              final color = Color.lerp(
                _kClay,
                _kCream,  // warm highlight colour
                shimmerStrength * 0.55,
              )!.withValues(alpha: finalAlpha);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              );
            }),
          ),
        );
      },
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
      ('…', 'Wait\n5s',      false),
      ('①', 'Bars\nRamp',    false),
      ('②', 'Crying\n×10',   true),
      ('③', 'Quiet\nReset',  false),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(steps.length, (i) {
          final (num, label, expanded) = steps[i];
          final isActive = i == activeIdx;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: expanded ? 32 : 18,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? _kClay : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 5),
              Text(num, style: TextStyle(
                color: isActive ? _kCream : Colors.white24,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              )),
              Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive ? Colors.white38 : Colors.white12,
                  fontSize: 8,
                  height: 1.4,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
