import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeVideoPlayer extends StatelessWidget {
  const NativeVideoPlayer({super.key});

  static const _channel = MethodChannel('com.moonboon/video_player');

  static Future<void> startPip() => _channel.invokeMethod('startPip');
  static Future<void> play()     => _channel.invokeMethod('play');
  static Future<void> pause()    => _channel.invokeMethod('pause');

  @override
  Widget build(BuildContext context) {
    return const UiKitView(
      viewType: 'com.moonboon/native_video_player',
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
