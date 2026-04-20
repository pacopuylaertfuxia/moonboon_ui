import '../found_monitor.dart';
import 'setup_error_type.dart';
import 'final_configuration_step.dart';

sealed class MonitorState {}

final class MonitorInitial extends MonitorState {}

final class MonitorChargeStep extends MonitorState {}

final class MonitorBluetoothPermissionDeniedStep extends MonitorState {}

final class MonitorStateNotSignedIn extends MonitorState {}

final class MonitorFound extends MonitorState {
  final List<FoundMonitor> devices;
  final bool isConnecting;
  final bool isStillScanning;
  final String friendlyName;
  final bool isLaunchedToChangeWiFi;

  MonitorFound(
    this.devices, {
    this.isConnecting = false,
    this.isStillScanning = false,
    this.friendlyName = '',
    this.isLaunchedToChangeWiFi = false,
  });
}

final class MonitorAlreadyTaken extends MonitorState {}

final class MonitorWiFiPasswordInputError extends MonitorState {
  final String ssid;
  MonitorWiFiPasswordInputError(this.ssid);
}

final class MonitorScanningWiFi extends MonitorState {
  final String monitorName;
  MonitorScanningWiFi(this.monitorName);
}

final class MonitorScanningWiFiResult extends MonitorState {
  final String monitorName;
  final List<String> ssids;
  MonitorScanningWiFiResult(this.monitorName, this.ssids);
}

final class MonitorWiFiPasswordInput extends MonitorState {
  final String ssid;
  MonitorWiFiPasswordInput(this.ssid);
}

final class MonitorFinalConfiguration extends MonitorState {
  final String monitorName;
  final FinalConfigurationStep step;
  MonitorFinalConfiguration(this.monitorName, this.step);
}

final class MonitorSoundMonitoringConsentStep extends MonitorState {}

final class MonitorStreamingConsentStep extends MonitorState {}

final class MonitorNoiseDetectionStep extends MonitorState {}

final class MonitorProvisioningSuccess extends MonitorState {
  final int monitorId;
  final bool isLaunchedToChangeWiFi;

  MonitorProvisioningSuccess(
    this.monitorId, {
    this.isLaunchedToChangeWiFi = false,
  });
}

final class ChangeWiFiInstructionsStep extends MonitorState {}

final class MonitorSetupErrorState extends MonitorState {
  final SetupErrorType errorType;
  MonitorSetupErrorState(this.errorType);
}
