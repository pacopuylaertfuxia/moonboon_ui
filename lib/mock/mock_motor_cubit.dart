import 'package:flutter_bloc/flutter_bloc.dart';
import '../pairing/bloc/pair_device_state.dart';

/// Auto-plays through the motor pairing flow — no real BLE, pure UI.
class MockMotorCubit extends Cubit<PairDeviceState> {
  MockMotorCubit() : super(PairDeviceStatePowerUp());

  static const _mockDevices = ['Paco\'s Motor', 'Moonboon Motor'];

  void nextStep() {
    final s = state;
    if (s is PairDeviceStatePowerUp) {
      emit(PairDeviceStateTurnOn());
    } else if (s is PairDeviceStateTurnOn) {
      emit(PairDeviceStateTurnOnBluetooth());
    } else if (s is PairDeviceStateTurnOnBluetooth) {
      emit(PairDeviceStateBluetoothPermission());
    }
  }

  void bluetoothPermissionGranted() {
    emit(PairDeviceStateScanningStep());
    _delay(2500, () => emit(PairDeviceStateFound(_mockDevices)));
  }

  void bluetoothPermissionDenied() => emit(PairDeviceStateBluetoothPermissionDenied());

  void goToPreviousStep() {
    final s = state;
    if (s is PairDeviceStateTurnOn) {
      emit(PairDeviceStatePowerUp());
    } else if (s is PairDeviceStateTurnOnBluetooth) {
      emit(PairDeviceStateTurnOn());
    } else if (s is PairDeviceStateDeviceSelected) {
      emit(PairDeviceStateFound(_mockDevices));
    } else if (s is PairDeviceStateBluetoothPermission ||
        s is PairDeviceStateBluetoothPermissionDenied ||
        s is PairDeviceStateScanningStep ||
        s is PairDeviceStateFound) {
      emit(PairDeviceStateTurnOnBluetooth());
    }
  }

  void selectDevice(String deviceName) => emit(PairDeviceStateDeviceSelected(deviceName));

  void connectToDevice(String deviceName, {String friendlyName = ''}) {
    final name = friendlyName.isEmpty ? deviceName : friendlyName;
    const steps = [
      (0,    0.08),
      (900,  0.28),
      (1800, 0.50),
      (2700, 0.72),
      (3600, 1.00),
    ];
    for (final (delayMs, progress) in steps) {
      _delay(delayMs, () => emit(PairDeviceStateActivating(name, progress)));
    }
    _delay(4500, () => emit(PairDeviceStatePaired()));
  }

  void goToGetNotifiedStep() => emit(PairDeviceStateGetNotified());

  void enableNotifications() {
    // In the playground just pop — no real notifications
  }

  // ── Mock error states ─────────────────────────────────────────────────────
  void simulateBluetoothDenied() => emit(PairDeviceStateBluetoothPermissionDenied());
  void simulateError() => emit(PairDeviceStateError('Could not start scanning. Make sure the motor is in pairing mode.'));
  void simulateTimeout() => emit(PairDeviceStateTimedOut());
  void simulateMultipleFound() => emit(PairDeviceStateFound(_mockDevices));
  void simulateInvalidBond() => emit(PairDeviceStateInvalidBond('AA:BB:CC:DD:EE:FF'));

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _delay(int ms, void Function() action) {
    Future.delayed(Duration(milliseconds: ms), () {
      if (!isClosed) action();
    });
  }
}
