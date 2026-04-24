sealed class PairDeviceState {}

final class PairDeviceStatePowerUp extends PairDeviceState {}

final class PairDeviceStateTurnOn extends PairDeviceState {}

final class PairDeviceStateTurnOnBluetooth extends PairDeviceState {}

final class PairDeviceStateBluetoothPermission extends PairDeviceState {}

final class PairDeviceStateBluetoothPermissionDenied extends PairDeviceState {}

final class PairDeviceStateEnterPairingMode extends PairDeviceState {}

final class PairDeviceStateScanningStep extends PairDeviceState {}

final class PairDeviceStateLoading extends PairDeviceState {}

final class PairDeviceStateActivating extends PairDeviceState {
  final String deviceName;
  final double progress;
  PairDeviceStateActivating(this.deviceName, this.progress);
}

final class PairDeviceStateError extends PairDeviceState {
  final String message;
  PairDeviceStateError(this.message);
}

final class PairDeviceStateInvalidBond extends PairDeviceState {
  final String address;
  PairDeviceStateInvalidBond(this.address);
}

final class PairDeviceStateTimedOut extends PairDeviceState {}

final class PairDeviceStateFound extends PairDeviceState {
  final List<String> deviceNames;
  PairDeviceStateFound(this.deviceNames);
}

final class PairDeviceStateDeviceSelected extends PairDeviceState {
  final String deviceName;
  PairDeviceStateDeviceSelected(this.deviceName);
}

final class PairDeviceStatePaired extends PairDeviceState {}

final class PairDeviceStateGetNotified extends PairDeviceState {}
