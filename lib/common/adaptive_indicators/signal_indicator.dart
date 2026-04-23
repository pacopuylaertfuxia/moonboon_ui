import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme_colors.dart';

class SignalIndicator extends StatelessWidget {
  const SignalIndicator({super.key, required this.signalStrength, this.size = 24.0});

  final double signalStrength;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return SvgPicture.asset(
      _getSignalIconAsset(),
      height: size,
      width: size,
      colorMapper: _SignalIconColorMapper(
        activeColor: colors.textPrimary,
        inactiveColor: colors.textPrimary.withValues(alpha: 0.2),
      ),
    );
  }

  String _getSignalIconAsset() {
    if (signalStrength >= 0.78) return 'assets/icons/signal/signal_max.svg';
    if (signalStrength >= 0.67) return 'assets/icons/signal/signal_high.svg';
    if (signalStrength >= 0.56) return 'assets/icons/signal/signal_mid.svg';
    if (signalStrength >= 0.44) return 'assets/icons/signal/signal_low.svg';
    return 'assets/icons/signal/signal_none.svg';
  }
}

class _SignalIconColorMapper extends ColorMapper {
  final Color activeColor;
  final Color inactiveColor;
  const _SignalIconColorMapper({required this.activeColor, required this.inactiveColor});

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    if (color == const Color(0xFF010101)) return activeColor;
    if (color == const Color(0xFFCDCDCD)) return inactiveColor;
    return color;
  }
}
