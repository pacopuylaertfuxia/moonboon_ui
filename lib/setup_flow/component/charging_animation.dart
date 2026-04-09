import 'package:flutter/material.dart';

class ChargingAnimation extends StatefulWidget {
  final double height;
  final double imageWidth;
  final double imageHeight;

  const ChargingAnimation({
    super.key,
    this.height = 150,
    this.imageWidth = 157,
    this.imageHeight = 697,
  });

  @override
  State<ChargingAnimation> createState() => _ChargingAnimationState();
}

class _ChargingAnimationState extends State<ChargingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.34, 1.2, 0.8, 1.0),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _controller.forward(from: 0);
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final startOffset = widget.height + 200;
            const endOffset = 30.0;
            final currentOffset =
                startOffset + (endOffset - startOffset) * _animation.value;
            return Transform.translate(
              offset: Offset(0, currentOffset),
              child: Align(
                alignment: Alignment.topCenter,
                child: Transform.scale(
                  scale: 1.2,
                  child: SizedBox(
                    width: widget.imageWidth,
                    height: widget.imageHeight,
                    child: Image.asset(
                      'assets/illustrations/monitor/illustration_usb_c_cable.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
