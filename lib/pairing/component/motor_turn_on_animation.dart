import 'package:flutter/material.dart';
import '../motor_type.dart';

/// Animated "Turn on the motor" illustration.
///
/// Basic  — uses motor_top_view.png (top-view, 3 buttons horizontal).
/// Premium — uses motor_premium_turn_on.png (back-view, dials + BT vertical).
class MotorTurnOnAnimation extends StatefulWidget {
  final MotorType motorType;

  const MotorTurnOnAnimation({super.key, required this.motorType});

  @override
  State<MotorTurnOnAnimation> createState() => _MotorTurnOnAnimationState();
}

class _MotorTurnOnAnimationState extends State<MotorTurnOnAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _phase1Scale;
  late final Animation<double> _phase1HoleRadius;
  late final Animation<double> _phase1OverlayOpacity;
  late final Animation<double> _crossfade;
  late final Animation<double> _phase2Scale;
  late final Animation<double> _phase2HoleRadius;
  late final Animation<double> _phase2OverlayOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..forward();

    _phase1Scale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.05, 0.45, curve: Curves.easeIn)),
    );
    _phase1HoleRadius = Tween<double>(begin: 120.0, end: 28.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.08, 0.45, curve: Curves.easeIn)),
    );
    _phase1OverlayOpacity = Tween<double>(begin: 0.0, end: 0.80).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.08, 0.35, curve: Curves.easeIn)),
    );
    _crossfade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.43, 0.57, curve: Curves.easeInOut)),
    );
    _phase2Scale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.60, 1.0, curve: Curves.easeIn)),
    );
    _phase2HoleRadius = Tween<double>(begin: 120.0, end: 28.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.63, 1.0, curve: Curves.easeIn)),
    );
    _phase2OverlayOpacity = Tween<double>(begin: 0.0, end: 0.80).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.63, 0.88, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = widget.motorType == MotorType.premium;
    final imagePath = isPremium
        ? 'assets/images/motor_premium_turn_on.png'
        : 'assets/images/motor_top_view.png';
    final displayW = isPremium ? 207.0 : 204.0;
    final displayH = isPremium ? 267.0 : 201.0;
    final phase1Offset = isPremium ? const Offset(0.5, 0.52) : const Offset(0.32, 0.54);
    final phase2Offset = isPremium ? const Offset(0.5, 0.40) : const Offset(0.68, 0.54);

    return SizedBox(
      height: displayH,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final phase1Opacity = (1.0 - _crossfade.value).clamp(0.0, 1.0);
            final phase2Opacity = _crossfade.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: phase1Opacity,
                  child: _SpotlightView(
                    imagePath: imagePath,
                    imageWidth: displayW,
                    imageHeight: displayH,
                    scale: _phase1Scale.value,
                    holeRadius: _phase1HoleRadius.value,
                    overlayOpacity: _phase1OverlayOpacity.value,
                    holeFractionalOffset: phase1Offset,
                  ),
                ),
                Opacity(
                  opacity: phase2Opacity,
                  child: _SpotlightView(
                    imagePath: imagePath,
                    imageWidth: displayW,
                    imageHeight: displayH,
                    scale: _phase2Scale.value,
                    holeRadius: _phase2HoleRadius.value,
                    overlayOpacity: _phase2OverlayOpacity.value,
                    holeFractionalOffset: phase2Offset,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SpotlightView extends StatelessWidget {
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final double scale;
  final double holeRadius;
  final double overlayOpacity;
  final Offset holeFractionalOffset;

  const _SpotlightView({
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.scale,
    required this.holeRadius,
    required this.overlayOpacity,
    required this.holeFractionalOffset,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final holeCenter = Offset(
          w * holeFractionalOffset.dx,
          imageHeight * holeFractionalOffset.dy,
        );
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale,
              child: Image.asset(imagePath, width: imageWidth, height: imageHeight, fit: BoxFit.contain),
            ),
            if (overlayOpacity > 0)
              CustomPaint(
                size: Size(w, imageHeight),
                painter: _SpotlightPainter(
                  center: holeCenter,
                  radius: holeRadius,
                  opacity: overlayOpacity,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double opacity;

  const _SpotlightPainter({
    required this.center,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: opacity));
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.radius != radius || old.opacity != opacity || old.center != center;
}
