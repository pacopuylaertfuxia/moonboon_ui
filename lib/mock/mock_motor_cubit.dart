import 'package:flutter_bloc/flutter_bloc.dart';
import '../pairing/bloc/pair_device_state.dart';

/// Auto-plays through the motor pairing flow — no real BLE, pure UI.
class MockMotorCubit extends Cubit<PairDeviceState> {
  MockMotorCubit() : super(PairDeviceStatePowerUp());

  static const _mockDevices = ['Paco\'s Motor', 'Moonboon Motor'];

  void nextStep() {
    final s = state;
    if (s is PairDeviceStatePowerUp) emit(PairDeviceStateTurnOn());
    else if (s is PairDeviceStateTurnOn) emit(PairDeviceStateTurnOnBluetooth());
    else if (s is PairDeviceStateTurnOnBluetooth) emit(PairDeviceStateBluetoothPermission());
    else if (s is PairDeviceStateBluetoothPermission) emit(PairDeviceStateEnterPairingMode());
    else if (s is PairDeviceStateEnterPairingMode) {
      emit(PairDeviceStateScanningStep());
      _delay(2500, () => emit(PairDeviceStateFound(_mockDevices.take(1).toList())));
    }
  }

  void goToPreviousStep() {
    final s = state;
    if (s is PairDeviceStateTurnOn) emit(PairDeviceStatePowerUp());
    else if (s is PairDeviceStateTurnOnBluetooth) emit(PairDeviceStateTurnOn());
    else if (s is PairDeviceStateBluetoothPermission) emit(PairDeviceStateTurnOnBluetooth());
    else if (s is PairDeviceStateBluetoothPermissionDenied) emit(PairDeviceStateTurnOnBluetooth());
    else if (s is PairDeviceStateEnterPairingMode) emit(PairDeviceStateBluetoothPermission());
    else if (s is PairDeviceStateScanningStep || s is PairDeviceStateFound) {
      emit(PairDeviceStateEnterPairingMode());
    }
  }

  void connectToDevice(String deviceName) {
    emit(PairDeviceStateLoading());
    _delay(1500, () => emit(PairDeviceStatePaired()));
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
