import 'package:flutter/material.dart';

/// Replaces context.text.* from the main app's localization.
/// Hardcoded English strings for the UI playground.
extension AppStrings on BuildContext {
  _Strings get text => const _Strings();
}

class _Strings {
  const _Strings();

  // Setup flow
  String get monitor_setup_charge_device => 'Charge your monitor';
  String get monitor_setup_charge_device_description =>
      'Make sure your monitor is charged and powered on before connecting.';
  String get monitor_setup_looking_for_your_monitor => 'Looking for your monitor';
  String get monitor_setup_found => 'Monitor found';
  String get monitor_setup_looking_for_wi_fi => 'Looking for Wi-Fi networks';
  String get monitor_setup_connecting_to_wifi => 'Connecting to Wi-Fi...';
  String get monitor_setup_provisioning => 'Setting up your monitor...';
  String get monitor_setup_uploading_credentials => 'Uploading credentials...';
  String get monitor_setup_checking_firmware => 'Checking firmware version...';
  String get monitor_setup_upgrading_firmware => 'Upgrading firmware...';
  String get monitor_setup_upgrading_firmware_first_milestone =>
      'Firmware upgrade in progress (50%)...';
  String get monitor_setup_upgrading_firmware_second_milestone =>
      'Almost done (75%)...';
  String get monitor_setup_finalizing => 'Finalizing setup...';
  String get monitor_setup_noise_detection_title => 'Sound detection';
  String get monitor_setup_noise_detection_description =>
      'Set how sensitive you want the sound detection to be.';
  String get monitor_setup_wi_fi_password => 'Wi-Fi password';

  // Pairing
  String get baby_monitors_name => 'Baby monitors';
  String get monitor_pair_select_monitor_to_connect_to =>
      'Select the monitor you want to connect to';
  String get monitor_pair_friendly_name_hint => 'Monitor name';
  String get monitor_pair_continue => 'Continue';
  String get monitor_pair_change_wifi_title => 'Change Wi-Fi';
  String get monitor_pair_change_wifi_description =>
      'Your monitor will reconnect to the new Wi-Fi network.';
  String get monitor_pair_allow_bluetooth_description =>
      'Bluetooth access is required to connect to your monitor.';
  String get monitor_pair_already_in_use_error_title =>
      'Monitor already in use';
  String get monitor_pair_already_in_use_error_description =>
      'This monitor is already connected to another account.';
  String get monitor_pair_already_in_use_error_button => 'Got it';
  String get monitor_pair_not_found_error_title => 'Monitor not found';
  String get monitor_pair_not_found_error_description =>
      'Make sure your monitor is powered on and nearby.';
  String get monitor_pair_not_found_while_changing_wifi_error_title =>
      'Monitor not found';
  String get monitor_pair_not_found_while_changing_wifi_error_description =>
      'Make sure your monitor is powered on and in range.';
  String get monitor_pair_final_configuration_error_title =>
      'Setup failed';
  String get monitor_pair_final_configuration_error_description =>
      'Something went wrong during setup. Please try again.';
  String get monitor_pair_bluetooth_off_error_description =>
      'Please enable Bluetooth and try again.';
  String get monitor_pair_unable_to_connect_to_wifi_error_description =>
      'Could not connect to this network. Check the password and try again.';
  String get monitor_pair_provisioning_success_title =>
      'Monitor ready!';
  String get monitor_pair_provisioning_success_button => 'Go to my monitor';
  String get monitor_pair_allow_sound_monitoring_title =>
      'Allow sound monitoring';
  String get monitor_pair_allow_sound_monitoring_description =>
      'Moonboon uses audio to detect sounds from your baby. Read our ';
  String get privacy_policy_link => 'Privacy Policy';
  String get privacy_policy_url =>
      'https://moonboon.com/privacy';
  String get faq_url => 'https://moonboon.com/faq';
  String get serial_number => 'Serial number';
  String get give_consent => 'Enable sound monitoring';
  String get disable => 'Disable';
  String get try_again => 'Try again';
  String get open_settings => 'Open Settings';
  String get next => 'Next';
  String get scan_again => 'Scan again';
  String get allow_bluetooth_title => 'Allow Bluetooth access';
  String get allow_bluetooth_description =>
      'Bluetooth access is required to connect to your motor.';

  // Motor pairing
  String get motor_pairing_power_up => 'Power up the motor';
  String get motor_pairing_power_up_description =>
      'Connect the power cable to the motor and plug it in.';
  String get motor_pairing_turn_on => 'Turn on the motor';
  String get motor_pairing_turn_on_power_button =>
      'Press the power button on the motor.';
  String get motor_pairing_turn_on_knobs =>
      'Turn both knobs to the maximum position to power on.';
  String get motor_pairing_turn_on_bluetooth => 'Activate Bluetooth';
  String get motor_pairing_press_bluetooth_button =>
      'Press the Bluetooth button on the back of the motor.';
  String get motor_pairing_looking => 'Looking for your motor...';
  String get motor_pairing_activating => 'Activating motor...';
  String get pairing_onboarding_flow_fifth_step_title => 'Enter pairing mode';
  String get press_button_description =>
      'Hold the pairing button until the light flashes blue.';
  String get connect => 'Connect';
  String get pairing_paired_title => 'Motor paired!';
  String get get_notified_title => 'Get notified';
  String get get_notified_description =>
      'Enable notifications to get alerts from your motor.';
  String get enable_notifications => 'Enable notifications';
  String get get_notified_secondary_cta => 'Not now';
  String get device_connection_state_connecting => 'Connecting...';
  String get pairing_error_could_not_start_scanning_title =>
      'Could not find motor';
}

extension StringUrlExtension on String {
  void openUrl({BuildContext? context}) {
    // No-op in playground — would open a browser in production
  }
}
