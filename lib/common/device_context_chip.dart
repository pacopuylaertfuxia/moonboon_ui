import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme_colors.dart';

/// Shows which Moonboon device is active and lets the user link it to a nap.
/// Appears above the "Start nap" CTA when motor or monitor is running.
class DeviceContextChip extends StatelessWidget {
  final bool isMotorRunning;
  final bool isMonitorActive;

  /// Called when user taps the link action. Null when a nap is already active.
  final VoidCallback? onStartNap;

  const DeviceContextChip({
    super.key,
    required this.isMotorRunning,
    required this.isMonitorActive,
    this.onStartNap,
  });

  bool get _visible => isMotorRunning || isMonitorActive;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final c = context.color;

    // Prefer motor context if both active; monitor otherwise
    final isMotor = isMotorRunning;
    final icon = isMotor
        ? 'assets/icons/controls/replay.svg'
        : 'assets/icons/controls/camera.svg';
    final label = isMotor ? 'Motor running' : 'Monitor active';

    return GestureDetector(
      onTap: onStartNap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: c.surfacePrimary,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: c.borderNormal),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing active dot
            _PulseDot(c: c),
            const SizedBox(width: 6),
            SvgPicture.asset(
              icon,
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textSecondary),
            ),
            if (onStartNap != null) ...[
              const SizedBox(width: 8),
              Container(width: 1, height: 12, color: c.borderNormal),
              const SizedBox(width: 8),
              Text(
                'Log nap',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: c.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final ThemeColors c;
  const _PulseDot({required this.c});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.c.brandPrimary.withValues(alpha: 0.4 + _anim.value * 0.6),
        ),
      ),
    );
  }
}
