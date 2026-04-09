import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme_colors.dart';
import '../motor_type.dart';

class BluetoothScanningAnimation extends StatefulWidget {
  final MotorType motorType;
  final double size;

  const BluetoothScanningAnimation({
    super.key,
    required this.motorType,
    this.size = 220,
  });

  @override
  State<BluetoothScanningAnimation> createState() =>
      _BluetoothScanningAnimationState();
}

class _BluetoothScanningAnimationState
    extends State<BluetoothScanningAnimation> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      ),
    );
    _animations = _controllers
        .map(
          (c) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOut),
          ),
        )
        .toList();
    _startStaggered();
  }

  Future<void> _startStaggered() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 600));
      if (mounted) _controllers[i].repeat();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final illustration = _illustrationFor(widget.motorType, isDark);
    final ringColor = context.color.brandPrimary;
    final size = widget.size;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._animations.map(
            (anim) => AnimatedBuilder(
              animation: anim,
              builder: (context, _) {
                final p = anim.value;
                return Opacity(
                  opacity: (1.0 - p).clamp(0.0, 1.0),
                  child: Container(
                    width: size * (0.44 + p * 0.56),
                    height: size * (0.44 + p * 0.56),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ringColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SvgPicture.asset(
            illustration,
            width: size * 0.42,
            height: size * 0.42,
          ),
        ],
      ),
    );
  }

  String _illustrationFor(MotorType type, bool isDark) => switch (type) {
    MotorType.basic => isDark
        ? 'assets/illustrations/illustration_pairing_select_basic_dark.svg'
        : 'assets/illustrations/illustration_pairing_select_basic_light.svg',
    MotorType.premium => isDark
        ? 'assets/illustrations/illustration_pairing_select_premium_dark.svg'
        : 'assets/illustrations/illustration_pairing_select_premium_light.svg',
  };
}
