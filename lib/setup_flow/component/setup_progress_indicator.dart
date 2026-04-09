import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/theme_colors.dart';
import '../bloc/final_configuration_step.dart';
import 'typewriter_cycling_text.dart';

const List<String> _babyMessages = [
  'Warming up the crib...',
  'Counting tiny toes...',
  'Fluffing the blankie...',
  'Whispering lullabies...',
  'Tuning in to giggles...',
  'Tiptoeing past the nursery...',
  'Calibrating cuddle sensors...',
  'Rocking gently...',
  'Listening for coos...',
  'Folding tiny socks...',
  'Brewing midnight milk...',
  'Winding the mobile...',
  'Shushing softly...',
  'Perfecting the swaddle...',
  'Consulting the teddy bear...',
  'Syncing with the stork...',
  'Testing the nightlight...',
  'Humming a melody...',
  'Tucking in the corners...',
  'Sprinkling sleepy dust...',
  'Checking the moon phases...',
  'Gathering sweet dreams...',
  'Polishing the pacifier...',
  'Scheduling nap time...',
  'Stretching tiny fingers...',
  'Yawning sympathetically...',
  'Prepping the snuggle zone...',
  'Booping the nose...',
  'Reading a bedtime story...',
  'Almost there, little one...',
];

double _stepProgress(FinalConfigurationStep step) => switch (step) {
  FinalConfigurationStep.connectingToWiFi => 0.08,
  FinalConfigurationStep.provisioning => 0.22,
  FinalConfigurationStep.uploadingAwsCredential => 0.38,
  FinalConfigurationStep.checkingFirmwareVersion => 0.50,
  FinalConfigurationStep.upgradingFirmware => 0.78,
  FinalConfigurationStep.firstFirmwareUpgradeProcessCheck => 0.86,
  FinalConfigurationStep.secondFirmwareUpgradeProcessCheck => 0.92,
  FinalConfigurationStep.finalizing => 1.0,
};

class SetupProgressIndicator extends StatefulWidget {
  final FinalConfigurationStep step;
  final bool isComplete;

  const SetupProgressIndicator({
    super.key,
    required this.step,
    this.isComplete = false,
  });

  @override
  State<SetupProgressIndicator> createState() => _SetupProgressIndicatorState();
}

class _SetupProgressIndicatorState extends State<SetupProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _z1Controller;
  late AnimationController _z2Controller;
  late AnimationController _z3Controller;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: widget.isComplete ? 1.0 : _stepProgress(widget.step),
    );
    _z1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _z2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _z3Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    if (widget.isComplete) _startZzzLoop();
  }

  void _startZzzLoop() async {
    while (mounted) {
      _z1Controller.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _z2Controller.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _z3Controller.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1200));
    }
  }

  @override
  void didUpdateWidget(SetupProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isComplete && oldWidget.step != widget.step) {
      _progressController.animateTo(
        _stepProgress(widget.step),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _z1Controller.dispose();
    _z2Controller.dispose();
    _z3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isComplete) return _buildCompleteView(context);

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        final progress = _progressController.value;
        final percent = (progress * 100).round();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 240,
              width: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _ProgressRingPainter(
                      progress: 1.0,
                      strokeWidth: 14,
                      color: context.color.surfaceSecondary,
                    ),
                  ),
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _ProgressRingPainter(
                      progress: progress,
                      strokeWidth: 14,
                      color: context.color.surfaceTertiary,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 190, maxWidth: 190),
                    child: Image.asset(
                      'assets/illustrations/monitor/illustration_monitor_front.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Progress:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 24 / 16,
                    color: context.color.brandPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 28 / 18,
                    color: context.color.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TypewriterCyclingText(
              messages: _babyMessages,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 28 / 18,
                color: context.color.textTertiary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompleteView(BuildContext context) {
    final zColor = context.color.brandPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              child: Image.asset(
                'assets/images/monitor_setup_success.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned.fill(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _ZzzLetter(controller: _z1Controller, label: 'z', fontSize: 18, offsetX: 28, offsetY: -20, color: zColor),
                  _ZzzLetter(controller: _z2Controller, label: 'Z', fontSize: 24, offsetX: 46, offsetY: -46, color: zColor),
                  _ZzzLetter(controller: _z3Controller, label: 'Z', fontSize: 30, offsetX: 58, offsetY: -76, color: zColor),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Sweet dreams are incoming',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.color.textTertiary),
        ),
        const SizedBox(height: 8),
        Text(
          'Moving the monitor? Switch WiFi in device settings.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.color.textTertiary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  const _ProgressRingPainter({required this.progress, required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.progress != progress || old.color != color;
}

class _ZzzLetter extends StatelessWidget {
  final AnimationController controller;
  final String label;
  final double fontSize;
  final double offsetX;
  final double offsetY;
  final Color color;

  const _ZzzLetter({
    required this.controller,
    required this.label,
    required this.fontSize,
    required this.offsetX,
    required this.offsetY,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = CurvedAnimation(parent: controller, curve: const Interval(0.0, 0.85, curve: Curves.easeIn));
    final rise = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final dy = offsetY - rise.value * 24;
        final alpha = (1.0 - opacity.value).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(offsetX, dy),
          child: Opacity(
            opacity: alpha,
            child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: color, height: 1)),
          ),
        );
      },
    );
  }
}
