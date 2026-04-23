import 'dart:async';
import 'package:flutter/material.dart';

/// Cycles through [messages] with a typewriter effect.
class TypewriterCyclingText extends StatefulWidget {
  final List<String> messages;
  final TextStyle? style;
  final Duration charInterval;
  final Duration holdDuration;

  const TypewriterCyclingText({
    super.key,
    required this.messages,
    this.style,
    this.charInterval = const Duration(milliseconds: 40),
    this.holdDuration = const Duration(seconds: 4),
  });

  @override
  State<TypewriterCyclingText> createState() => _TypewriterCyclingTextState();
}

class _TypewriterCyclingTextState extends State<TypewriterCyclingText> {
  Timer? _cycleTimer;
  Timer? _typewriterTimer;
  int _messageIndex = 0;
  String _displayedText = '';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _cycleTimer = Timer.periodic(widget.holdDuration, (_) {
      _messageIndex = (_messageIndex + 1) % widget.messages.length;
      _startTyping();
    });
  }

  void _startTyping() {
    _typewriterTimer?.cancel();
    _charIndex = 0;
    _displayedText = '';
    final fullText = widget.messages[_messageIndex];
    _typewriterTimer = Timer.periodic(widget.charInterval, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_charIndex < fullText.length) {
        setState(() {
          _charIndex++;
          _displayedText = fullText.substring(0, _charIndex);
        });
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Text(
        _displayedText,
        style: widget.style,
      ),
    );
  }
}
