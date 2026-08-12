import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/button.dart';
import '../common/fade_overlay.dart';
import '../common/pair_device_body.dart';
import '../common/setup_sheet_body.dart';
import '../mock/mock_monitor_cubit.dart';
import '../strings/app_strings.dart';
import '../theme/theme_colors.dart';
import 'bloc/final_configuration_step.dart';
import 'component/setup_progress_indicator.dart';
import 'component/wifi_radar_animation.dart';
import 'bloc/monitor_state.dart';
import 'bloc/setup_error_type.dart';
import 'component/charging_animation.dart';
import 'component/found_wifi_network.dart';
import '../common/device_pick_card.dart';
import 'found_monitor.dart';
import 'setup_text_field.dart';
import 'component/noise_detection_body.dart';
import 'component/sound_monitoring_consent_body.dart';
import 'component/streaming_consent_body.dart';
import 'component/welcome_gift_screen.dart';
import '../common/monitor_troubleshoot_page.dart';

class MonitorProvisioningPage extends StatefulWidget {
  final VoidCallback? onMonitorAdded;
  final VoidCallback? onNavigatedBack;
  final bool isLaunchedToChangeWiFi;

  const MonitorProvisioningPage({
    super.key,
    this.onMonitorAdded,
    this.onNavigatedBack,
    this.isLaunchedToChangeWiFi = false,
  });

  @override
  State<MonitorProvisioningPage> createState() =>
      _MonitorProvisioningPageState();
}

class _MonitorProvisioningPageState extends State<MonitorProvisioningPage> {
  final _nameInputController = SetupTextController();
  final _passwordInputController = SetupTextController();
  var _noiseDetectionLevel = NoiseDetectionLevel.medium;
  var _onlyBabyCries = false;

  int? _stepFor(MonitorState state) => switch (state) {
    MonitorChargeStep() => 1,
    MonitorSearchingStep() => 2,
    MonitorFound() => 2,
    MonitorScanningWiFi() => 3,
    MonitorScanningWiFiResult() => 3,
    MonitorWiFiPasswordInput() => 3,
    MonitorWiFiPasswordInputError() => 3,
    MonitorFinalConfiguration() => 4,
    MonitorSoundMonitoringConsentStep() => null,
    MonitorStreamingConsentStep() => null,
    MonitorNoiseDetectionStep() => null,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MockMonitorCubit, MonitorState>(
      listenWhen: (_, curr) => curr is MonitorWelcomeGiftStep,
      listener: (context, state) {
        final cubit = context.read<MockMonitorCubit>();
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => WelcomeGiftScreen(
            onGetStarted: () {
              Navigator.of(context).pop();
              cubit.proceedFromWelcomeGift();
            },
          ),
        ));
      },
      builder: (context, state) {
        final child = switch (state) {
          MonitorChargeStep() => _buildChargeMonitorStep(context),
          MonitorSearchingStep() => _buildChargeMonitorStep(context),
          MonitorFound s => _buildFound(context, s),
          MonitorAlreadyTaken() => _buildAlreadyTaken(context),
          MonitorWiFiPasswordInputError s => _buildWiFiPasswordInputStep(
            context,
            s.ssid,
            previouslyFailed: true,
          ),
          MonitorSetupErrorState s => _buildError(
            context,
            s.errorType,
            widget.isLaunchedToChangeWiFi,
          ),
          MonitorBluetoothPermissionDeniedStep() =>
            _buildBluetoothPermissionDeniedStep(context),
          MonitorSoundMonitoringConsentStep() => _buildSoundMonitoringConsentStep(context),
          MonitorStreamingConsentStep() => _buildStreamingConsentStep(context),
          MonitorFinalConfiguration s => _buildFinalConfigurationStep(
            s.monitorName,
            s.step,
          ),
          MonitorScanningWiFi s => _buildScanningWiFiStep(s.monitorName),
          MonitorScanningWiFiResult s => _buildScanningWiFiResult(context, s),
          ChangeWiFiInstructionsStep() =>
            _buildChangeWiFiInstructionStep(context),
          MonitorWiFiPasswordInput s => _buildWiFiPasswordInputStep(
            context,
            s.ssid,
          ),
          MonitorNoiseDetectionStep() => _buildNoiseDetectionStep(context),
          _ => const SizedBox.shrink(),
        };

        final step = _stepFor(state);
        final isNoiseStep = state is MonitorNoiseDetectionStep;
        return SetupSheetBody(
          step: step,
          totalSteps: 5,
          backgroundColor: isNoiseStep ? context.color.surfaceSecondary : null,
          child: child,
        );
      },
    );
  }

  // ── Step builders ─────────────────────────────────────────────

  Widget _buildFound(BuildContext context, MonitorFound state) {
    return state.devices.length == 1
        ? _singleFoundMonitor(
            context,
            state.devices.first,
            state.isConnecting,
            state.friendlyName,
            state.isLaunchedToChangeWiFi,
          )
        : PairDeviceBody(
            key: const ValueKey('foundStepMultiple'),
            onBackButtonPressed: () =>
                context.read<MockMonitorCubit>().startSetupFlow(),
            title: 'Multiple Monitors found',
            description:
                'Look for the serial number on the back of your device to identify it.',
            titleBottomPadding: 16,
            isLoading: state.isStillScanning,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: state.devices
                    .map(
                      (device) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: DevicePickCard(
                          imageAsset: 'assets/images/babymonitor_packshot.png',
                          serialNumber: device.serialNumber,
                          onConnect: () =>
                              context.read<MockMonitorCubit>().selectDevice(
                                device,
                              ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
  }

  Widget _singleFoundMonitor(
    BuildContext context,
    FoundMonitor device,
    bool isConnecting,
    String friendlyName,
    bool isLaunchedToChangeWifi,
  ) {
    _nameInputController.setLoading(isConnecting);
    _nameInputController.setText(friendlyName);
    _nameInputController.setReadOnly(isLaunchedToChangeWifi);
    return SingleChildScrollView(
      child: PairDeviceBody(
        key: const ValueKey('foundStepSingle'),
        title: context.text.monitor_setup_found,
        asset: 'assets/illustrations/monitor/illustration_monitor_front.png',
        isLoading: isConnecting,
        child: SetupTextField(
          controller: _nameInputController,
          validationRule: (name) => name.isNotEmpty,
          hintText: context.text.monitor_pair_friendly_name_hint,
          textCapitalization: TextCapitalization.sentences,
          withInputField: !widget.isLaunchedToChangeWiFi,
          onSubmitted: (name) {
            FocusScope.of(context).unfocus();
            context.read<MockMonitorCubit>().connectToDevice(device, name);
          },
        ),
      ),
    );
  }

  Widget _buildChargeMonitorStep(BuildContext context) {
    final keyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;
    return PairDeviceBody(
      key: const ValueKey('chargeMonitorStep'),
      title: context.text.monitor_setup_charge_device,
      description: context.text.monitor_setup_charge_device_description,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WifiRadarAnimation(size: keyboardUp ? 143 : 294),
            if (!keyboardUp) ...[
              const SizedBox(height: 12),
              const ChargingAnimation(height: 160),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchingStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('searchingStep'),
      title: context.text.motor_pairing_looking,
      child: const WifiRadarAnimation(size: 294),
    );
  }

  Widget _buildChangeWiFiInstructionStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('changeWiFiInstructionStep'),
      title: context.text.monitor_pair_change_wifi_title,
      description: context.text.monitor_pair_change_wifi_description,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () =>
          context.read<MockMonitorCubit>().startSetupFlow(),
      asset: 'assets/illustrations/monitor/illustration_monitor_front.png',
    );
  }

  Widget _buildBluetoothPermissionDeniedStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('bluetoothPermissionDeniedStep'),
      title: context.text.allow_bluetooth_title,
      description: context.text.monitor_pair_allow_bluetooth_description,
      primaryButtonLabel: context.text.open_settings,
      secondaryButtonLabel: context.text.try_again,
      onPrimaryButtonPressed: () {
        // no-op in playground
      },
      onSecondaryButtonPressed: () =>
          context.read<MockMonitorCubit>().startSetupFlow(),
      child: const SizedBox(height: 24),
    );
  }

  Widget _buildAlreadyTaken(BuildContext context) {
    return PairDeviceErrorBody(
      key: const ValueKey('alreadyInUse'),
      title: context.text.monitor_pair_already_in_use_error_title,
      description: context.text.monitor_pair_already_in_use_error_description,
      primaryButtonLabel: context.text.monitor_pair_already_in_use_error_button,
      onPrimaryButtonPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildError(
    BuildContext context,
    SetupErrorType errorType,
    bool isLaunchedToChangeWiFi,
  ) {
    String title;
    String description;

    switch (errorType) {
      case SetupErrorType.monitorNotFound:
        title = isLaunchedToChangeWiFi
            ? context
                .text
                .monitor_pair_not_found_while_changing_wifi_error_title
            : context.text.monitor_pair_not_found_error_title;
        description = isLaunchedToChangeWiFi
            ? context
                .text
                .monitor_pair_not_found_while_changing_wifi_error_description
            : context.text.monitor_pair_not_found_error_description;
      case SetupErrorType.monitorBluetoothErrorStep:
        title = context.text.monitor_pair_not_found_error_title;
        description =
            context.text.monitor_pair_bluetooth_off_error_description;
      default:
        title = context.text.monitor_pair_final_configuration_error_title;
        description =
            context.text.monitor_pair_final_configuration_error_description;
    }

    return PairDeviceErrorBody(
      key: const ValueKey('errorStep'),
      title: title,
      description: description,
      primaryButtonLabel: context.text.try_again,
      onPrimaryButtonPressed: () {
        if (errorType.canSkipWiFiStep) {
          context.read<MockMonitorCubit>().checkWiFiConnectionAndTryAgain();
        } else {
          context.read<MockMonitorCubit>().startSetupFlow();
        }
      },
      onTroubleshoot: () => openMonitorTroubleshootPage(context),
    );
  }

  Widget _buildWiFiPasswordInputStep(
    BuildContext context,
    String ssid, {
    bool previouslyFailed = false,
  }) {
    return SingleChildScrollView(
      child: PairDeviceBody(
        key: const ValueKey('wiFiPasswordInputStep'),
        title: ssid,
        description: previouslyFailed
            ? context
                .text
                .monitor_pair_unable_to_connect_to_wifi_error_description
            : null,
        child: SetupTextField(
          controller: _passwordInputController,
          validationRule: (p) => p.length >= 8 && p.length <= 63,
          hintText: context.text.monitor_setup_wi_fi_password,
          isObscured: true,
          onSubmitted: (password) async {
            FocusScope.of(context).unfocus();
            await Future.delayed(const Duration(milliseconds: 500));
            if (context.mounted) {
              context.read<MockMonitorCubit>().setWiFiCredentials(ssid, password);
            }
          },
        ),
      ),
    );
  }

  Widget _buildScanningWiFiResult(
    BuildContext context,
    MonitorScanningWiFiResult state,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return PairDeviceBody(
      key: const ValueKey('scanningWiFiResultStep'),
      title: state.monitorName,
      asset: 'assets/illustrations/monitor/illustration_monitor_front.png',
      child: state.ssids.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 256),
                    child: WrapFade(
                      color: isDarkMode
                          ? context.color.surfaceSecondary
                          : context.color.surfacePrimary,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 16,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: state.ssids.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 2,
                            color: context.color.surfaceTertiary,
                          ),
                          itemBuilder: (context, index) {
                            final ssid = state.ssids[index];
                            return GestureDetector(
                              onTap: () => context
                                  .read<MockMonitorCubit>()
                                  .setPasswordFor(ssid),
                              child: FoundWifiNetwork(ssid: ssid),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Button(
                  buttonLabel: Text(context.text.scan_again),
                  onPressed: () =>
                      context.read<MockMonitorCubit>().scanWifiAPs(),
                  variant: ButtonVariant.primary,
                  size: ButtonSize.standard,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildScanningWiFiStep(String monitorName) {
    return PairDeviceBody(
      key: const ValueKey('scanningWiFiStep'),
      title: monitorName,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const WifiRadarAnimation(size: 294),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Looking for WiFi networks…',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.color.textTertiary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.color.textTertiary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFinalConfigurationStep(
    String monitorName,
    FinalConfigurationStep step,
  ) {
    return PairDeviceBody(
      key: const ValueKey('finalConfigurationStep'),
      title: monitorName,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        child: SetupProgressIndicator(step: step),
      ),
    );
  }

  Widget _buildSoundMonitoringConsentStep(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('soundMonitoringConsentStep'),
      child: SoundMonitoringConsentBody(
        onContinue: () =>
            context.read<MockMonitorCubit>().giveSoundMonitoringConsent(),
        onDisable: () =>
            context.read<MockMonitorCubit>().disableSoundMonitoring(),
      ),
    );
  }

  Widget _buildNoiseDetectionStep(BuildContext context) {
    return NoiseDetectionBody(
      key: const ValueKey('noiseDetectionStep'),
      title: context.text.monitor_setup_noise_detection_title,
      subtitle: context.text.monitor_setup_noise_detection_description,
      level: _noiseDetectionLevel,
      onlyBabyCries: _onlyBabyCries,
      onLevelSelected: (l) => setState(() => _noiseDetectionLevel = l),
      onOnlyBabyCriesChanged: (v) => setState(() => _onlyBabyCries = v),
      onContinue: () => context.read<MockMonitorCubit>().setNoiseDetectionLevel(
        _noiseDetectionLevel,
        _onlyBabyCries,
      ),
    );
  }


  Widget _buildStreamingConsentStep(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('streamingConsentStep'),
      child: StreamingConsentBody(
        onContinue: () => context.read<MockMonitorCubit>().giveStreamingConsent(),
      ),
    );
  }

  @override
  void dispose() {
    _nameInputController.dispose();
    _passwordInputController.dispose();
    super.dispose();
  }
}

