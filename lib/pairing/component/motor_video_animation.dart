import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Plays a local video asset as a setup-flow animation.
///
/// The video fills the available width, loops by default, and starts playing
/// immediately. Pass [loop: false] for one-shot animations (e.g. success).
class MotorVideoAnimation extends StatefulWidget {
  final String assetPath;
  final bool loop;

  const MotorVideoAnimation({
    super.key,
    required this.assetPath,
    this.loop = true,
  });

  @override
  State<MotorVideoAnimation> createState() => _MotorVideoAnimationState();
}

class _MotorVideoAnimationState extends State<MotorVideoAnimation> {
  late final VideoPlayerController _ctrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.asset(widget.assetPath)
      ..setLooping(widget.loop)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _ctrl.play();
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: _ctrl.value.aspectRatio,
      child: VideoPlayer(_ctrl),
    );
  }
}
