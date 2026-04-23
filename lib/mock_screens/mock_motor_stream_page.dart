import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../common/button.dart';
import '../common/moonboon_scaffold.dart';
import '../theme/theme_colors.dart';

// ---------------------------------------------------------------------------
// Motor state
// ---------------------------------------------------------------------------

enum _MotorState { ready, running, edit, loading }

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class MockMotorStreamPage extends StatefulWidget {
  const MockMotorStreamPage({super.key});

  @override
  State<MockMotorStreamPage> createState() => _MockMotorStreamPageState();
}

class _MockMotorStreamPageState extends State<MockMotorStreamPage> {
  _MotorState _motorState = _MotorState.ready;
  Duration _duration = const Duration(hours: 1, minutes: 30);
  int _tempo = 50;
  bool _fadeOut = false;
  bool _notify = true;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    return MoonboonScaffold(
      appBar: MoonboonAppBar(title: 'Motor Connect'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: topInset + 24,
                left: 18,
                right: 18,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: _CountDownTimer(
                      programDuration: _duration,
                      motorState: _motorState,
                      onStartDrag: () =>
                          setState(() => _motorState = _MotorState.edit),
                      onStopDrag: (d) => setState(() {
                        _duration = d;
                        _motorState = _MotorState.ready;
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _TempoSeekBar(
                    motorState: _motorState,
                    tempo: _tempo,
                    onStartDrag: () =>
                        setState(() => _motorState = _MotorState.edit),
                    onStopDrag: (t) => setState(() {
                      _tempo = t;
                      if (_motorState == _MotorState.edit) {
                        _motorState = _MotorState.running;
                      }
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Switch.adaptive(
                              value: _fadeOut,
                              onChanged: (v) => setState(() => _fadeOut = v),
                            ),
                            Text(
                              'Fade out',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Switch.adaptive(
                              value: _notify,
                              onChanged: (v) => setState(() => _notify = v),
                            ),
                            Text(
                              'Notify when ending',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Pinned bottom button
          Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              0,
              18,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: _buildBottomButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    switch (_motorState) {
      case _MotorState.edit:
        return Row(
          children: [
            Expanded(
              child: Button(
                onPressed: () =>
                    setState(() => _motorState = _MotorState.running),
                buttonLabel: Text(
                  'Update',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                variant: ButtonVariant.primary,
                size: ButtonSize.lg,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Button(
                onPressed: () =>
                    setState(() => _motorState = _MotorState.running),
                buttonLabel: Text(
                  'Discard',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                variant: ButtonVariant.secondary,
                size: ButtonSize.lg,
              ),
            ),
          ],
        );
      case _MotorState.running:
        return SizedBox(
          width: double.infinity,
          child: Button(
            onPressed: () => setState(() => _motorState = _MotorState.ready),
            buttonLabel: Text(
              'Stop',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            variant: ButtonVariant.primary,
            size: ButtonSize.lg,
          ),
        );
      case _MotorState.ready:
      case _MotorState.loading:
        return SizedBox(
          width: double.infinity,
          child: Button(
            onPressed: _motorState == _MotorState.loading
                ? () {}
                : () => setState(() => _motorState = _MotorState.running),
            buttonLabel: Text(
              'Start',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            variant: ButtonVariant.primary,
            size: ButtonSize.lg,
            disabled: _motorState == _MotorState.loading,
          ),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// CountDownTimer
// ---------------------------------------------------------------------------

const double _kCircularTimerWidth = 270.0;
const double _kCircularBarWidth = 23.0;
const double _kTopArcGapDegrees = 22.0;
const Duration _kMaxProgramDuration = Duration(hours: 12);
const double _kStartAngleDegrees =
    (270.0 + _kTopArcGapDegrees / 2.0) % 360.0;
const double _kSweepAngleDegrees = 360.0 - _kTopArcGapDegrees;
const double _kProgressBoundariesFix = 0.05;
const double _kStartAngleRadians = (_kStartAngleDegrees * math.pi / 180.0);
const double _kSweepAngleRadians = (_kSweepAngleDegrees * math.pi / 180.0);

class _CountDownTimer extends StatefulWidget {
  final Duration programDuration;
  final _MotorState motorState;
  final VoidCallback onStartDrag;
  final Function(Duration) onStopDrag;

  const _CountDownTimer({
    required this.programDuration,
    required this.motorState,
    required this.onStartDrag,
    required this.onStopDrag,
  });

  @override
  State<_CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<_CountDownTimer> {
  double _dragProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _dragProgress = (widget.programDuration.inMilliseconds /
            _kMaxProgramDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  void didUpdateWidget(covariant _CountDownTimer old) {
    super.didUpdateWidget(old);
    if (widget.programDuration != old.programDuration) {
      _dragProgress = (widget.programDuration.inMilliseconds /
              _kMaxProgramDuration.inMilliseconds)
          .clamp(0.0, 1.0);
    }
  }

  void _handleDragUpdate(double p) {
    setState(() => _dragProgress = p.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return SizedBox(
      width: _kCircularTimerWidth,
      height: _kCircularTimerWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _CircularSeekBar(
            progress: _dragProgress,
            progressColor: c.surfaceQuaternary,
            backgroundColor: c.overlayLevel2,
            borderColor: c.borderNormal,
            onDragStart: widget.onStartDrag,
            onDragUpdate: _handleDragUpdate,
            onDragEnd: () {
              final ms = (_kMaxProgramDuration.inMilliseconds * _dragProgress)
                  .round();
              widget.onStopDrag(Duration(milliseconds: ms));
            },
          ),
          _TimerText(
            motorState: widget.motorState,
            programDuration: widget.programDuration,
            currentProgressForEdit: _dragProgress,
            textColor: c.textSecondary,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CircularSeekBar
// ---------------------------------------------------------------------------

class _CircularSeekBar extends StatefulWidget {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onDragStart;
  final Function(double) onDragUpdate;
  final VoidCallback onDragEnd;

  const _CircularSeekBar({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<_CircularSeekBar> createState() => _CircularSeekBarState();
}

class _CircularSeekBarState extends State<_CircularSeekBar> {
  void _onPanUpdate(DragUpdateDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = details.localPosition.dx - center.dx;
    final dy = details.localPosition.dy - center.dy;
    double angleDeg;
    if (dx < 0 && dy < 0) {
      angleDeg = 270.0 + (math.atan2(-dy, -dx) * 180 / math.pi);
    } else {
      angleDeg = 90.0 - (math.atan2(-dy, dx) * 180 / math.pi);
      if (angleDeg < 0) angleDeg += 360.0;
    }
    final minDeg = _kTopArcGapDegrees / 2.0;
    final maxDeg = 360.0 - (_kTopArcGapDegrees / 2.0);
    final cur = widget.progress;
    double p;
    if (angleDeg > maxDeg && cur < _kProgressBoundariesFix) {
      p = cur;
    } else if (angleDeg < minDeg && cur > (1.0 - _kProgressBoundariesFix)) {
      p = cur;
    } else if (angleDeg <= minDeg) {
      p = 0.0;
    } else if (angleDeg >= maxDeg) {
      p = 1.0;
    } else {
      p = ((angleDeg - minDeg) / (360.0 - _kTopArcGapDegrees)).clamp(0.0, 1.0);
    }
    widget.onDragUpdate(p);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        onPanStart: (_) => widget.onDragStart(),
        onPanUpdate: (d) => _onPanUpdate(d, size),
        onPanEnd: (_) => widget.onDragEnd(),
        child: CustomPaint(
          size: size,
          painter: _CircularSeekBarPainter(
            progress: widget.progress,
            progressBackgroundColor: widget.backgroundColor,
            progressColor: widget.progressColor,
            thumbColor: Colors.white,
            strokeWidth: _kCircularBarWidth,
            startAngleRadians: _kStartAngleRadians,
            sweepAngleRadians: _kSweepAngleRadians,
            borderColor: widget.borderColor,
          ),
        ),
      );
    });
  }
}

class _CircularSeekBarPainter extends CustomPainter {
  final double progress;
  final Color progressBackgroundColor;
  final Color progressColor;
  final Color thumbColor;
  final double strokeWidth;
  final double startAngleRadians;
  final double sweepAngleRadians;
  final Color borderColor;

  _CircularSeekBarPainter({
    required this.progress,
    required this.progressBackgroundColor,
    required this.progressColor,
    required this.thumbColor,
    required this.strokeWidth,
    required this.startAngleRadians,
    required this.sweepAngleRadians,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final outerR = radius + strokeWidth / 2;
    final innerR = radius - strokeWidth / 2;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    Offset pt(double a, double r) =>
        Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));

    void drawCap(double angle) {
      final o = pt(angle, outerR);
      final i = pt(angle, innerR);
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset((o.dx + i.dx) / 2, (o.dy + i.dy) / 2),
            radius: strokeWidth / 2),
        angle + math.pi / 2 - math.pi / 2,
        math.pi,
        false,
        borderPaint,
      );
    }

    canvas.drawArc(Rect.fromCircle(center: center, radius: outerR),
        startAngleRadians, sweepAngleRadians, false, borderPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: innerR),
        startAngleRadians, sweepAngleRadians, false, borderPaint);
    drawCap(startAngleRadians);
    drawCap(startAngleRadians + sweepAngleRadians);

    canvas.drawArc(
      rect,
      startAngleRadians,
      sweepAngleRadians,
      false,
      Paint()
        ..color = progressBackgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    final sweep = sweepAngleRadians * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      rect,
      startAngleRadians,
      sweep,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    final thumbAngle = startAngleRadians + sweep;
    final thumbCenter = Offset(
        center.dx + radius * math.cos(thumbAngle),
        center.dy + radius * math.sin(thumbAngle));
    canvas.drawCircle(
        thumbCenter, strokeWidth / 2, Paint()..color = progressColor);
    canvas.drawCircle(thumbCenter, 4.0, Paint()..color = thumbColor);
  }

  @override
  bool shouldRepaint(_CircularSeekBarPainter old) =>
      old.progress != progress ||
      old.progressColor != progressColor ||
      old.progressBackgroundColor != progressBackgroundColor ||
      old.borderColor != borderColor;
}

// ---------------------------------------------------------------------------
// TimerText
// ---------------------------------------------------------------------------

class _TimerText extends StatefulWidget {
  final _MotorState motorState;
  final Duration programDuration;
  final double currentProgressForEdit;
  final Color textColor;

  const _TimerText({
    required this.motorState,
    required this.programDuration,
    required this.currentProgressForEdit,
    required this.textColor,
  });

  @override
  State<_TimerText> createState() => _TimerTextState();
}

class _TimerTextState extends State<_TimerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _colonCtrl;
  late Animation<double> _colonOpacity;

  @override
  void initState() {
    super.initState();
    _colonCtrl = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..repeat(reverse: true);
    _colonOpacity =
        Tween<double>(begin: 0.2, end: 1.0).animate(_colonCtrl);
  }

  @override
  void dispose() {
    _colonCtrl.dispose();
    super.dispose();
  }

  String _endsAt(Duration d) {
    final t = DateTime.now().add(d);
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Duration display;
    if (widget.motorState == _MotorState.edit ||
        widget.motorState == _MotorState.ready) {
      final ms = (_kMaxProgramDuration.inMilliseconds *
              widget.currentProgressForEdit)
          .round();
      display = Duration(milliseconds: ms);
      if (display.inSeconds < 60) display = const Duration(seconds: 60);
    } else {
      display = widget.programDuration;
    }

    final h = display.inHours;
    final m = display.inMinutes.remainder(60);
    final s = display.inSeconds.remainder(60);
    final c = widget.textColor;

    Widget content;
    switch (widget.motorState) {
      case _MotorState.ready:
      case _MotorState.edit:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set timer',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: c),
            ),
            const SizedBox(height: 10),
            Text(
              '${h}h ${m.toString().padLeft(2, '0')}m',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: c),
            ),
          ],
        );
        break;
      case _MotorState.running:
        final timeStr =
            '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(timeStr.split(':')[0],
                    style: TextStyle(
                      fontFamily: 'KeplerStd',
                      fontSize: 60,
                      fontWeight: FontWeight.normal,
                      color: c,
                    )),
                FadeTransition(
                  opacity: _colonOpacity,
                  child: Text(':',
                      style: TextStyle(
                        fontFamily: 'KeplerStd',
                        fontSize: 60,
                        fontWeight: FontWeight.normal,
                        color: c,
                      )),
                ),
                Text(timeStr.split(':')[1],
                    style: TextStyle(
                      fontFamily: 'KeplerStd',
                      fontSize: 60,
                      fontWeight: FontWeight.normal,
                      color: c,
                    )),
              ],
            ),
            if (h > 0 || m > 0 || s > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Ends at ${_endsAt(display)}',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: c),
                ),
              ),
          ],
        );
        break;
      case _MotorState.loading:
        content = CircularProgressIndicator(color: c);
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: DefaultTextStyle(
        key: ValueKey(widget.motorState),
        style: TextStyle(color: c),
        textAlign: TextAlign.center,
        child: content,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TempoSeekBar
// ---------------------------------------------------------------------------

enum _TempoBucket { slow, medium, fast }

_TempoBucket _bucketFor(int t) {
  if (t < 33) return _TempoBucket.slow;
  if (t < 67) return _TempoBucket.medium;
  return _TempoBucket.fast;
}

class _TempoSeekBar extends StatefulWidget {
  final _MotorState motorState;
  final int tempo;
  final VoidCallback onStartDrag;
  final Function(int) onStopDrag;

  const _TempoSeekBar({
    required this.motorState,
    required this.tempo,
    required this.onStartDrag,
    required this.onStopDrag,
  });

  @override
  State<_TempoSeekBar> createState() => _TempoSeekBarState();
}

class _TempoSeekBarState extends State<_TempoSeekBar> {
  int _progress = 50;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _progress = widget.tempo;
  }

  @override
  void didUpdateWidget(_TempoSeekBar old) {
    super.didUpdateWidget(old);
    if (!_dragging && widget.tempo != old.tempo) {
      setState(() => _progress = widget.tempo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final bucket = _bucketFor(_progress);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TempoLabel(
              text: 'Slow',
              icon: 'assets/icons/tempo/slow.svg',
              isActive: bucket == _TempoBucket.slow,
              activeColor: c.textPrimary,
              inactiveColor: c.textQuaternary,
              onTap: () {
                widget.onStartDrag();
                setState(() => _progress = 16);
                widget.onStopDrag(16);
              },
            ),
            _TempoLabel(
              text: 'Medium',
              icon: 'assets/icons/tempo/medium.svg',
              isActive: bucket == _TempoBucket.medium,
              activeColor: c.textPrimary,
              inactiveColor: c.textQuaternary,
              onTap: () {
                widget.onStartDrag();
                setState(() => _progress = 50);
                widget.onStopDrag(50);
              },
            ),
            _TempoLabel(
              text: 'Fast',
              icon: 'assets/icons/tempo/fast.svg',
              isActive: bucket == _TempoBucket.fast,
              activeColor: c.textPrimary,
              inactiveColor: c.textQuaternary,
              onTap: () {
                widget.onStartDrag();
                setState(() => _progress = 84);
                widget.onStopDrag(84);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 25,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              _MoonboonSlider(
                onStartDrag: () {
                  setState(() => _dragging = true);
                  widget.onStartDrag();
                },
                onDrag: (v) => setState(() => _progress = v),
                onStopDrag: (v) {
                  setState(() => _dragging = false);
                  widget.onStopDrag(v);
                },
                currentProgress: _progress,
                progressColor: c.surfaceQuaternary,
                progressBackgroundColor: c.overlayLevel2,
              ),
              if (_progress >= 13)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Text(
                    '$_progress%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TempoLabel
// ---------------------------------------------------------------------------

class _TempoLabel extends StatelessWidget {
  final String text;
  final String icon;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _TempoLabel({
    required this.text,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        key: ValueKey('$text-$isActive'),
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 3),
              SvgPicture.asset(
                icon,
                colorFilter:
                    ColorFilter.mode(color, BlendMode.srcIn),
                width: 16,
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MoonboonSlider
// ---------------------------------------------------------------------------

class _MoonboonSlider extends StatefulWidget {
  final VoidCallback onStartDrag;
  final Function(int) onDrag;
  final Function(int) onStopDrag;
  final int currentProgress;
  final Color progressBackgroundColor;
  final Color progressColor;

  const _MoonboonSlider({
    required this.onStartDrag,
    required this.onDrag,
    required this.onStopDrag,
    required this.currentProgress,
    required this.progressBackgroundColor,
    required this.progressColor,
  });

  @override
  State<_MoonboonSlider> createState() => _MoonboonSliderState();
}

class _MoonboonSliderState extends State<_MoonboonSlider> {
  static const double _h = 25.0;

  int _fromDx(double dx, double w) =>
      (((dx - _h / 2) / (w - _h)) * 99 + 1).clamp(1, 100).toInt();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      return GestureDetector(
        onHorizontalDragStart: (_) => widget.onStartDrag(),
        onHorizontalDragUpdate: (d) =>
            widget.onDrag(_fromDx(d.localPosition.dx, w)),
        onHorizontalDragEnd: (d) =>
            widget.onStopDrag(_fromDx(d.localPosition.dx, w)),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: widget.currentProgress.toDouble(),
            end: widget.currentProgress.toDouble(),
          ),
          duration: const Duration(milliseconds: 100),
          builder: (context, value, child) {
            return CustomPaint(
              size: Size(w, _h),
              painter: _SliderPainter(
                progress: value,
                progressColor: widget.progressColor,
                backgroundColor: widget.progressBackgroundColor,
              ),
            );
          },
        ),
      );
    });
  }
}

class _SliderPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  _SliderPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final r = Radius.circular(h / 2);
    final thumb = h / 2;

    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, h), r),
        Paint()..color = backgroundColor);

    double progW =
        (progress / 100 * (size.width - 2 * thumb) + 2 * thumb)
            .clamp(2 * thumb, size.width);
    if (progress <= 1 && size.width > 2 * thumb) progW = 2 * thumb;
    if (progress < 1) progW = 0;

    if (progW > 0) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, progW, h), r),
          Paint()..color = progressColor);
    }

    final tx = (thumb + progress / 100 * (size.width - 2 * thumb))
        .clamp(thumb, size.width - thumb);
    canvas.drawCircle(
        Offset(tx, h / 2), thumb, Paint()..color = progressColor);
    canvas.drawCircle(
        Offset(tx, h / 2), thumb / 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.progress != progress ||
      old.progressColor != progressColor ||
      old.backgroundColor != backgroundColor;
}
