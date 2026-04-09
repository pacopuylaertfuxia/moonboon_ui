import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Pulse rings expanding outward from the monitor illustration.
class WifiRadarAnimation extends StatefulWidget {
  final double size;

  const WifiRadarAnimation({super.key, this.size = 240});

  @override
  State<WifiRadarAnimation> createState() => _WifiRadarAnimationState();
}

class _WifiRadarAnimationState extends State<WifiRadarAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(3, (i) {
                final value = (_pulseController.value + i * 0.33) % 1.0;
                return _PulseRing(progress: value, size: widget.size);
              }),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: widget.size * 0.7,
                  maxWidth: widget.size * 0.7,
                ),
                child: Image.asset(
                  'assets/illustrations/monitor/illustration_monitor_front.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double progress;
  final double size;

  const _PulseRing({required this.progress, required this.size});

  @override
  Widget build(BuildContext context) {
    final scale = 0.6 + (0.4 * progress);
    final opacity = (1.0 - progress).clamp(0.0, 0.3);
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: clay.withValues(alpha: opacity),
            width: 2,
          ),
        ),
      ),
    );
  }
}
