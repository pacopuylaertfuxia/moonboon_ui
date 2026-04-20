import 'package:flutter/services.dart';

class CryCallService {
  static const _channel = MethodChannel('com.moonboon/live_activity');
  static const _events  = EventChannel('com.moonboon/call_events');

  /// Stream of call states: "idle" | "ringing" | "answered" | "ended"
  Stream<String> get callStateStream =>
      _events.receiveBroadcastStream().map((e) => e as String);

  Future<void> reportCry({required String babyName}) async {
    await _channel.invokeMethod<void>('reportCry', {'babyName': babyName});
  }

  Future<void> endCall() async {
    await _channel.invokeMethod<void>('endCryCall');
  }

  /// Call this whenever sound level changes so native can manage the quiet timer.
  Future<void> updateSoundLevel(double level) async {
    await _channel.invokeMethod<void>('soundLevelUpdate', {'level': level});
  }

  Future<String> getCallState() async {
    return await _channel.invokeMethod<String>('getCallState') ?? 'idle';
  }

  /// Returns seconds remaining on the quiet timer, or null if timer is not running.
  Future<double?> getQuietRemaining() async {
    return await _channel.invokeMethod<double?>('getQuietRemaining');
  }
}
