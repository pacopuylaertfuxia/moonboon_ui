import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'live_activity_service.dart';
import 'live_activity_state.dart';

class LiveActivityCubit extends Cubit<LiveActivityState> {
  final LiveActivityService _service;
  Timer? _loopTimer;
  Timer? _audioSimTimer;
  Timer? _imageRotationTimer;
  var _loopTick = 0;
  var _audioSimTick = 0;
  var _imageRotationIndex = 0;

  static const _babyName   = 'Baby';
  static const _motorName  = 'Moonboon Motor';
  static const _statuses   = ['Sleeping', 'Awake', 'Crying'];
  static const _programs   = ['Gentle', 'Medium', 'Strong'];

  // Images on Desktop — file:// URLs work on simulator (same Mac filesystem).
  // Spaces = %20, apostrophes = %27 (percent-encoded for URL validity).
  static const _rotationImages = [
    'flutter_assets/assets/images/monitor_1.png',
    'flutter_assets/assets/images/monitor_2.png',
    'flutter_assets/assets/images/monitor_3.png',
  ];

  LiveActivityCubit(this._service) : super(const LiveActivityState());

  @override
  Future<void> close() {
    _loopTimer?.cancel();
    _audioSimTimer?.cancel();
    _imageRotationTimer?.cancel();
    return super.close();
  }

  // ── Monitor ───────────────────────────────────────────────────────────────

  Future<void> startMonitorA({String? imageUrl}) async {
    try {
      _imageRotationIndex = 0;
      final firstImage = imageUrl ?? _rotationImages[0];
      await _service.startMonitor(
        babyName:      _babyName,
        soundLevel:    state.soundLevel,
        statusLabel:   state.statusLabel,
        temperature:   state.temperature,
        batteryLevel:  state.monitorBattery,
        isCharging:    state.monitorCharging,
        imageUrl:      firstImage,
        designVariant: 1,
      );
      emit(state.copyWith(
        monitorActive: true,
        clearError: true,
        monitorVariant: 1,
      ));
      _startImageRotationIfNeeded();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> startMonitorB({String? imageUrl}) async {
    try {
      _imageRotationIndex = 0;
      final firstImage = imageUrl ?? _rotationImages[0];
      await _service.startMonitor(
        babyName:      _babyName,
        soundLevel:    state.soundLevel,
        statusLabel:   state.statusLabel,
        temperature:   state.temperature,
        batteryLevel:  state.monitorBattery,
        isCharging:    state.monitorCharging,
        imageUrl:      firstImage,
        designVariant: 2,
      );
      emit(state.copyWith(
        monitorActiveB: true,
        clearError: true,
        monitorVariant: 2,
      ));
      _startImageRotationIfNeeded();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Keep backward-compat alias
  Future<void> startMonitor({String? imageUrl, int designVariant = 1}) =>
      designVariant == 2 ? startMonitorB(imageUrl: imageUrl) : startMonitorA(imageUrl: imageUrl);

  Future<void> endMonitorA() async {
    try {
      await _service.endMonitor(variant: 1);
      final bothDone = !state.monitorActiveB;
      if (bothDone) _stopMonitorTimers();
      emit(state.copyWith(
        monitorActive: false,
        isSimulatingAudio: bothDone ? false : null,
        soundLevel: bothDone ? 0.05 : null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> endMonitorB() async {
    try {
      await _service.endMonitor(variant: 2);
      final bothDone = !state.monitorActive;
      if (bothDone) _stopMonitorTimers();
      emit(state.copyWith(
        monitorActiveB: false,
        isSimulatingAudio: bothDone ? false : null,
        soundLevel: bothDone ? 0.05 : null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Keep backward-compat alias
  Future<void> endMonitor() => endMonitorA();

  void _stopMonitorTimers() {
    _audioSimTimer?.cancel();
    _audioSimTimer = null;
    _imageRotationTimer?.cancel();
    _imageRotationTimer = null;
  }

  // ── Motor ─────────────────────────────────────────────────────────────────

  Future<void> startMotor() async {
    try {
      await _service.startMotor(
        motorName:    _motorName,
        isRunning:    state.motorRunning,
        program:      state.motorProgram,
        speed:        state.motorSpeed,
        batteryLevel: state.motorBattery,
        isCharging:   state.motorCharging,
      );
      emit(state.copyWith(motorActive: true, clearError: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> endMotor() async {
    try {
      await _service.endMotor();
      emit(state.copyWith(motorActive: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> endAll() async {
    try {
      await _service.endAll();
      _loopTimer?.cancel();
      _loopTimer = null;
      _stopMonitorTimers();
      emit(state.copyWith(
        monitorActive: false, monitorActiveB: false, motorActive: false,
        isAutoLooping: false, isSimulatingAudio: false,
        soundLevel: 0.05, clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // ── Controls — monitor ────────────────────────────────────────────────────

  Future<void> setSoundLevel(double level) async {
    emit(state.copyWith(soundLevel: level.clamp(0.0, 1.0)));
    await _pushMonitorUpdate();
  }

  Future<void> cycleStatus() async {
    final idx = (_statuses.indexOf(state.statusLabel) + 1) % _statuses.length;
    emit(state.copyWith(statusLabel: _statuses[idx]));
    if (state.statusLabel == 'Crying') {
      await _service.reportCry(_babyName);
    }
    await _pushMonitorUpdate();
  }

  void setTemperature(int temp) {
    emit(state.copyWith(temperature: temp));
    _pushMonitorUpdate();
  }

  Future<void> setMonitorBattery(int level) async {
    emit(state.copyWith(monitorBattery: level.clamp(0, 100)));
    await _pushMonitorUpdate();
  }

  // ── Controls — motor ──────────────────────────────────────────────────────

  Future<void> toggleMotorRunning() async {
    emit(state.copyWith(motorRunning: !state.motorRunning));
    await _pushMotorUpdate();
  }

  Future<void> cycleMotorProgram() async {
    final idx = (_programs.indexOf(state.motorProgram) + 1) % _programs.length;
    emit(state.copyWith(motorProgram: _programs[idx]));
    await _pushMotorUpdate();
  }

  Future<void> setMotorSpeed(int speed) async {
    emit(state.copyWith(motorSpeed: speed.clamp(1, 10)));
    await _pushMotorUpdate();
  }

  Future<void> setMotorBattery(int level) async {
    emit(state.copyWith(motorBattery: level.clamp(0, 100)));
    await _pushMotorUpdate();
  }

  // ── Auto-loop ─────────────────────────────────────────────────────────────

  void toggleAutoLoop() {
    if (state.isAutoLooping) {
      _loopTimer?.cancel();
      _loopTimer = null;
      emit(state.copyWith(isAutoLooping: false));
    } else {
      _loopTick = 0;
      emit(state.copyWith(isAutoLooping: true));
      _loopTimer = Timer.periodic(const Duration(seconds: 3), (_) => _onLoopTick());
    }
  }

  void _onLoopTick() {
    _loopTick++;
    final rng = math.Random();
    final spike = _loopTick % 10 == 0 || rng.nextDouble() < 0.08;
    final newLevel = spike
        ? (0.4 + rng.nextDouble() * 0.5).clamp(0.0, 1.0)
        : (state.soundLevel + (rng.nextDouble() - 0.5) * 0.1).clamp(0.0, 0.3);
    emit(state.copyWith(soundLevel: newLevel));
    _pushMonitorUpdate();
  }

  // ── Audio simulation — sine-wave oscillator, 400ms ticks ─────────────────

  void toggleAudioSimulation() {
    if (state.isSimulatingAudio) {
      _audioSimTimer?.cancel();
      _audioSimTimer = null;
      emit(state.copyWith(isSimulatingAudio: false, soundLevel: 0.05));
      _pushMonitorUpdate();
    } else {
      _audioSimTick = 0;
      emit(state.copyWith(isSimulatingAudio: true));
      _audioSimTimer = Timer.periodic(
        const Duration(milliseconds: 150),
        (_) => _onAudioSimTick(),
      );
    }
  }

  void _onAudioSimTick() {
    _audioSimTick++;
    // t in seconds at 150ms resolution
    final t = _audioSimTick * 0.15;
    final base    = 0.35 + 0.28 * math.sin(t * 1.6);        // slow breath swell
    final shimmer = 0.10 * math.sin(t * 8.5 + 0.8);         // fast shimmer
    final spike   = (t % 5.0 < 0.3) ? 0.30 : 0.0;           // sharp spike every 5s
    final level   = (base + shimmer + spike).clamp(0.0, 1.0);
    emit(state.copyWith(soundLevel: level));
    _pushMonitorUpdate();
  }

  // ── Image rotation ────────────────────────────────────────────────────────

  void _startImageRotationIfNeeded() {
    if (_imageRotationTimer != null) return; // already running
    _imageRotationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _advanceRotationImage(),
    );
  }

  Future<void> _advanceRotationImage() async {
    if (!state.monitorActive && !state.monitorActiveB) return;
    _imageRotationIndex = (_imageRotationIndex + 1) % _rotationImages.length;
    await _pushMonitorUpdate(imageUrl: _rotationImages[_imageRotationIndex]);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _pushMonitorUpdate({String? imageUrl}) async {
    if (!state.monitorActive && !state.monitorActiveB) return;
    try {
      await _service.updateMonitor(
        soundLevel:   state.soundLevel,
        statusLabel:  state.statusLabel,
        temperature:  state.temperature,
        batteryLevel: state.monitorBattery,
        isCharging:   state.monitorCharging,
        imageUrl:     imageUrl,
      );
    } catch (_) {}
  }

  /// Fires an AlertConfiguration on the Live Activity (triggers DI to expand)
  /// and optionally fires a cry notification for audio feedback.
  Future<void> triggerAlert({
    String statusLabel = 'Crying',
    String alertBody = 'Sound detected!',
  }) async {
    if (!state.monitorActive && !state.monitorActiveB) return;
    emit(state.copyWith(statusLabel: statusLabel));
    try {
      await _service.updateMonitor(
        soundLevel:   state.soundLevel,
        statusLabel:  statusLabel,
        temperature:  state.temperature,
        batteryLevel: state.monitorBattery,
        isCharging:   state.monitorCharging,
        alert:        true,
        alertTitle:   'Baby Monitor',
        alertBody:    alertBody,
      );
    } catch (_) {}
  }

  Future<void> playCrySound() async {
    try { await _service.playCrySound(); } catch (_) {}
  }

  Future<void> stopCrySound() async {
    try { await _service.stopCrySound(); } catch (_) {}
  }

  Future<void> fireNotification(String title, String body) async {
    try {
      await _service.fireNotification(title: title, body: body);
    } catch (_) {}
  }

  Future<void> _pushMotorUpdate() async {
    if (!state.motorActive) return;
    try {
      await _service.updateMotor(
        isRunning:    state.motorRunning,
        program:      state.motorProgram,
        speed:        state.motorSpeed,
        batteryLevel: state.motorBattery,
        isCharging:   state.motorCharging,
      );
    } catch (_) {}
  }
}
