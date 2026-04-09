enum SetupErrorType {
  disconnectedFromBluetooth(canSkipWiFiStep: false),
  monitorNotFound(canSkipWiFiStep: false),
  monitorFailedToConnect(canSkipWiFiStep: false),
  monitorFailedToGetProvisioningInfo(canSkipWiFiStep: true),
  monitorFailedToSetProvisioningInfo(canSkipWiFiStep: true),
  monitorProvisioningFailed(canSkipWiFiStep: true),
  monitorFailedToConnectToAws(canSkipWiFiStep: true),
  monitorBluetoothErrorStep(canSkipWiFiStep: false);

  final bool canSkipWiFiStep;
  const SetupErrorType({required this.canSkipWiFiStep});
}
