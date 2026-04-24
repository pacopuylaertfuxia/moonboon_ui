import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../common/button.dart';
import '../common/moonboon_scaffold.dart';
import '../common/surface_card.dart';
import '../theme/theme_colors.dart';

// ---------------------------------------------------------------------------
// Mock state
// ---------------------------------------------------------------------------

enum _MotorState { stopped, starting, running }

// ---------------------------------------------------------------------------
// Page (stateful to toggle stopped ↔ running)
// ---------------------------------------------------------------------------

class MockMotorDetailsPage extends StatefulWidget {
  const MockMotorDetailsPage({super.key});

  @override
  State<MockMotorDetailsPage> createState() => _MockMotorDetailsPageState();
}

class _MockMotorDetailsPageState extends State<MockMotorDetailsPage> {
  _MotorState _state = _MotorState.stopped;
  int? _startingPreset; // 0=short 1=medium 2=long

  void _startPreset(int preset) {
    setState(() {
      _state = _MotorState.starting;
      _startingPreset = preset;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _state = _MotorState.running);
    });
  }

  void _stop() => setState(() {
        _state = _MotorState.stopped;
        _startingPreset = null;
      });

  @override
  Widget build(BuildContext context) {
    return MoonboonScaffold(
      appBar: MoonboonAppBar(title: 'Motor Connect'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: appBarHeight() + 16,
            bottom: 48,
            left: 16,
            right: 16,
          ),
          child: SurfaceCard(
            child: _state == _MotorState.running
                ? _RunningMotorWidget(onStop: _stop)
                : _StoppedMotorWidget(
                    startingPreset: _state == _MotorState.starting
                        ? _startingPreset
                        : null,
                    onStart: _startPreset,
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stopped state
// ---------------------------------------------------------------------------

class _StoppedMotorWidget extends StatelessWidget {
  final int? startingPreset;
  final void Function(int preset) onStart;

  const _StoppedMotorWidget({
    required this.startingPreset,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: c.feedbackSuccess,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Motor Connect',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a sleep program',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: c.textTertiary,
                        ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: c.brandPrimary),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ProgramPresetItem(
            title: 'Short · 45 min',
            lengthFraction: 0.45,
            isLoading: startingPreset == 0,
            isDisabled:
                startingPreset != null && startingPreset != 0,
            onTap: () => onStart(0),
          ),
          _ProgramPresetItem(
            title: 'Medium · 65 min',
            lengthFraction: 0.65,
            isLoading: startingPreset == 1,
            isDisabled:
                startingPreset != null && startingPreset != 1,
            onTap: () => onStart(1),
          ),
          _ProgramPresetItem(
            title: 'Long · 85 min',
            lengthFraction: 0.85,
            isLoading: startingPreset == 2,
            isDisabled:
                startingPreset != null && startingPreset != 2,
            onTap: () => onStart(2),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Program preset item
// ---------------------------------------------------------------------------

class _ProgramPresetItem extends StatelessWidget {
  final String title;
  final double lengthFraction;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onTap;

  const _ProgramPresetItem({
    required this.title,
    required this.lengthFraction,
    required this.isLoading,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final radius = BorderRadius.circular(34);

    return GestureDetector(
      onTap: isLoading || isDisabled ? null : onTap,
      child: Container(
        height: 68,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: c.surfaceSecondary,
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              // Accent bar (replaces illustration)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: lengthFraction * 68,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.brandPrimary.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(34),
                      bottomLeft: Radius.circular(34),
                    ),
                  ),
                ),
              ),
              // Content row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.brandSecondary,
                      ),
                      child: isDisabled
                          ? const SizedBox.shrink()
                          : isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: onTap,
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: c.brandSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Running state
// ---------------------------------------------------------------------------

class _RunningMotorWidget extends StatelessWidget {
  final VoidCallback onStop;

  const _RunningMotorWidget({required this.onStop});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Running indicator
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: c.feedbackSuccess,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Motor is running',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Stats row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ends at',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: c.textTertiary,
                        ),
                  ),
                  Text(
                    '22:45',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tempo',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: c.textTertiary,
                        ),
                  ),
                  Text(
                    'Medium',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const Spacer(),
              // Progress ring
              SizedBox(
                width: 48,
                height: 48,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: 0.62,
                    trackColor: c.borderNormal.withValues(alpha: 0.2),
                    progressColor: c.borderNormal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Stop / navigate button
              Button(
                onPressed: onStop,
                variant: ButtonVariant.secondary,
                size: ButtonSize.icon,
                customHeight: 48,
                customWidth: 48,
                icon: Icon(
                  Icons.stop_rounded,
                  size: 24,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ring painter
// ---------------------------------------------------------------------------

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 6) / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final arc = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, track);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}
