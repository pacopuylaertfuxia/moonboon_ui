import 'package:flutter/services.dart';

class LiveActivityService {
  static const _channel = MethodChannel('com.moonboon/live_activity');

  // ── Monitor ────────────────────────────────────────────────────────────────

  Future<void> startMonitor({
    required String babyName,
    required double soundLevel,
    required String statusLabel,
    int? temperature,
    required int batteryLevel,
    required bool isCharging,
    String connectionState = 'connected',
    double wifiStrength = 1.0,
    String? imageUrl,
    int designVariant = 1,
  }) async {
    await _channel.invokeMethod('startMonitor', {
      'babyName': babyName,
      'soundLevel': soundLevel,
      'statusLabel': statusLabel,
      if (temperature != null) 'temp': temperature,
      'battery': batteryLevel,
      'charging': isCharging,
      'connection': connectionState,
      'wifi': wifiStrength,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'variant': designVariant,
    });
  }

  Future<void> updateMonitor({
    required double soundLevel,
    required String statusLabel,
    int? temperature,
    required int batteryLevel,
    required bool isCharging,
    String connectionState = 'connected',
    double wifiStrength = 1.0,
    String? imageUrl,
    bool alert = false,
    String alertTitle = 'Baby Monitor',
    String alertBody = '',
  }) async {
    await _channel.invokeMethod('updateMonitor', {
      'soundLevel': soundLevel,
      'statusLabel': statusLabel,
      if (temperature != null) 'temp': temperature,
      'battery': batteryLevel,
      'charging': isCharging,
      'connection': connectionState,
      'wifi': wifiStrength,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (alert) 'alert': true,
      if (alert) 'alertTitle': alertTitle,
      if (alert) 'alertBody': alertBody.isEmpty ? statusLabel : alertBody,
    });
  }

  Future<void> endMonitor({int variant = 1}) =>
      _channel.invokeMethod('endMonitor', {'variant': variant});

  // ── Motor ──────────────────────────────────────────────────────────────────

  Future<void> startMotor({
    required String motorName,
    required bool isRunning,
    required String program,
    required int speed,
    int? remainingSeconds,
    required int batteryLevel,
    required bool isCharging,
  }) async {
    await _channel.invokeMethod('startMotor', {
      'motorName': motorName,
      'isRunning': isRunning,
      'program': program,
      'speed': speed,
      if (remainingSeconds != null) 'remainingSeconds': remainingSeconds,
      'battery': batteryLevel,
      'charging': isCharging,
    });
  }

  Future<void> updateMotor({
    required bool isRunning,
    required String program,
    required int speed,
    int? remainingSeconds,
    required int batteryLevel,
    required bool isCharging,
  }) async {
    await _channel.invokeMethod('updateMotor', {
      'isRunning': isRunning,
      'program': program,
      'speed': speed,
      if (remainingSeconds != null) 'remainingSeconds': remainingSeconds,
      'battery': batteryLevel,
      'charging': isCharging,
    });
  }

  Future<void> endMotor() => _channel.invokeMethod('endMotor');

  // ── Shared ─────────────────────────────────────────────────────────────────

  Future<void> endAll() => _channel.invokeMethod('endAll');

  Future<void> reportCry(String babyName) =>
      _channel.invokeMethod('reportCry', {'babyName': babyName});

  Future<void> pushSoundLevel(double level) =>
      _channel.invokeMethod('soundLevelUpdate', {'level': level});

  Future<void> fireNotification({required String title, required String body}) =>
      _channel.invokeMethod('fireNotification', {'title': title, 'body': body});

  Future<void> playCrySound() => _channel.invokeMethod('playCrySound');
  Future<void> stopCrySound() => _channel.invokeMethod('stopCrySound');
}
