import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../setup_flow/found_monitor.dart';
import '../setup_flow/bloc/monitor_state.dart';
import '../setup_flow/bloc/final_configuration_step.dart';
import '../setup_flow/bloc/setup_error_type.dart';
import '../setup_flow/component/noise_detection_body.dart';

/// Auto-plays through the monitor setup flow using timers.
/// No real BLE, WiFi, or AWS — pure UI state machine.
class MockMonitorCubit extends Cubit<MonitorState> {
  MockMonitorCubit() : super(MonitorInitial());

  static const _mockMonitor = FoundMonitor(
    address: 'AA:BB:CC:DD:EE:FF',
    serialNumber: 'SBM123456',
  );
  static const _mockMonitorName = "Paco's Monitor";
  static const _mockWifiNetworks = [
    'Home WiFi',
    'iPhone Hotspot',
    'Moonboon-Guest',
    'Neighbors_5G',
  ];

  // ── Entry point ────────────────────────────────────────────────

  void checkCurrentUser({
    bool isLaunchedToChangeWiFi = false,
    String? friendlyName,
    String? serialNumber,
  }) {
    if (isLaunchedToChangeWiFi) {
      emit(ChangeWiFiInstructionsStep());
    } else {
      emit(MonitorChargeStep());
      // Auto-find the monitor after 2.5s
      _delay(2500, () {
        emit(MonitorFound(
          [_mockMonitor],
          friendlyName: friendlyName ?? _mockMonitorName,
          isStillScanning: false,
        ));
      });
    }
  }

  void startSetupFlow() {
    emit(MonitorChargeStep());
    _delay(2500, () {
      emit(MonitorFound(
        [_mockMonitor],
        friendlyName: _mockMonitorName,
      ));
    });
  }

  // ── Device selection & connection ─────────────────────────────

  void selectDevice(FoundMonitor device) {
    emit(MonitorFound([device], friendlyName: _mockMonitorName));
  }

  void connectToDevice(FoundMonitor device, String name) {
    emit(MonitorFound(
      [device],
      isConnecting: true,
      friendlyName: name,
    ));
    // Simulate connecting then WiFi scan
    _delay(1500, () => emit(MonitorScanningWiFi(name)));
    _delay(3000, () => emit(MonitorScanningWiFiResult(name, _mockWifiNetworks)));
  }

  void goToPreviousStep() {
    final current = state;
    if (current is MonitorFound) {
      emit(MonitorChargeStep());
    } else if (current is MonitorScanningWiFi ||
        current is MonitorScanningWiFiResult) {
      emit(MonitorFound([_mockMonitor], friendlyName: _mockMonitorName));
    } else if (current is MonitorWiFiPasswordInput ||
        current is MonitorWiFiPasswordInputError) {
      emit(MonitorScanningWiFiResult(_mockMonitorName, _mockWifiNetworks));
    }
  }

  // ── WiFi ───────────────────────────────────────────────────────

  void scanWifiAPs() {
    emit(MonitorScanningWiFi(_mockMonitorName));
    _delay(2000, () {
      emit(MonitorScanningWiFiResult(_mockMonitorName, _mockWifiNetworks));
    });
  }

  void setPasswordFor(String ssid) {
    emit(MonitorWiFiPasswordInput(ssid));
  }

  void setWiFiCredentials(String ssid, String password) {
    _runFinalConfiguration(_mockMonitorName);
  }

  void checkWiFiConnectionAndTryAgain() {
    _runFinalConfiguration(_mockMonitorName);
  }

  // ── Final configuration (mock timer chain) ────────────────────

  void _runFinalConfiguration(String name) {
    final steps = [
      (0, FinalConfigurationStep.connectingToWiFi),
      (1800, FinalConfigurationStep.provisioning),
      (3600, FinalConfigurationStep.uploadingAwsCredential),
      (5400, FinalConfigurationStep.checkingFirmwareVersion),
      (7200, FinalConfigurationStep.finalizing),
    ];

    for (final (delayMs, step) in steps) {
      _delay(delayMs, () => emit(MonitorFinalConfiguration(name, step)));
    }
    _delay(9000, () => emit(MonitorSoundMonitoringConsentStep()));
  }

  // ── Consent & noise detection ─────────────────────────────────

  void giveSoundMonitoringConsent() => emit(MonitorNoiseDetectionStep());

  void disableSoundMonitoring() => emit(MonitorNoiseDetectionStep());

  void setNoiseDetectionLevel(NoiseDetectionLevel level, bool onlyBabyCries) {
    emit(MonitorStreamingConsentStep());
  }

  void giveStreamingConsent() {
    if (!isClosed) close();
  }

  void refuseStreamingConsent() {
    if (!isClosed) close();
  }

  // ── Error simulation (for demo/testing) ───────────────────────

  void simulateError(SetupErrorType type) {
    emit(MonitorSetupErrorState(type));
  }

  void simulateAlreadyTaken() => emit(MonitorAlreadyTaken());

  void simulateBluetoothDenied() => emit(MonitorBluetoothPermissionDeniedStep());

  // ── Helpers ───────────────────────────────────────────────────

  Timer? _activeTimer;

  void _delay(int ms, VoidCallback action) {
    if (ms == 0) {
      action();
      return;
    }
    Future.delayed(Duration(milliseconds: ms), () {
      if (!isClosed) action();
    });
  }

  @override
  Future<void> close() {
    _activeTimer?.cancel();
    return super.close();
  }
}

typedef VoidCallback = void Function();
