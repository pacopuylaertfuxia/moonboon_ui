import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../common/button.dart';
import '../common/circular_loading_bar.dart';
import '../common/fade_overlay.dart';
import '../common/pair_device_body.dart';
import '../common/simple_circle_icon_button.dart';
import '../mock/mock_monitor_cubit.dart';
import '../strings/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/theme_colors.dart';
import 'bloc/final_configuration_step.dart';
import 'component/setup_progress_indicator.dart';
import 'component/wifi_radar_animation.dart';
import 'bloc/monitor_state.dart';
import 'bloc/setup_error_type.dart';
import 'component/charging_animation.dart';
import 'component/found_wifi_network.dart';
import 'found_monitor.dart';
import 'setup_text_field.dart';
import 'component/noise_detection_body.dart';

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
    MonitorFound() => 2,
    MonitorScanningWiFi() => 3,
    MonitorScanningWiFiResult() => 3,
    MonitorWiFiPasswordInput() => 3,
    MonitorWiFiPasswordInputError() => 3,
    MonitorFinalConfiguration() => 4,
    MonitorStreamingConsentStep() => 5,
    MonitorNoiseDetectionStep() => 5,
    _ => null,
  };

  Widget _buildStepper(int currentStep, int totalSteps) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final step = i + 1;
        final isCompleted = step < currentStep;
        final isCurrent = step == currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isCurrent ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: (isCurrent || isCompleted)
                  ? context.color.surfaceTertiary
                  : context.color.surfaceTertiary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MockMonitorCubit, MonitorState>(
      builder: (context, state) {
        final child = switch (state) {
          MonitorChargeStep() => _buildChargeMonitorStep(context),
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
          MonitorStreamingConsentStep() => _buildStreamingConsentStep(context),
          MonitorProvisioningSuccess() => _buildProvisioningSuccess(),
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
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: step != null ? 52.0 : 0.0),
              child: child,
            ),
            if (step != null)
              Positioned(
                bottom: 44,
                left: 0,
                right: 0,
                child: Center(child: _buildStepper(step, 5)),
              ),
            if (state is! MonitorStreamingConsentStep &&
                state is! MonitorNoiseDetectionStep &&
                state is! MonitorFinalConfiguration)
              Positioned(
                top: 8,
                right: 8,
                child: SimpleCircleIconButton(
                  width: 40,
                  height: 40,
                  color: Colors.transparent,
                  icon: SvgPicture.asset(
                    'assets/icons/help_circle.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    // no-op in playground
                  },
                ),
              ),
          ],
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
            title: context.text.baby_monitors_name,
            description:
                context.text.monitor_pair_select_monitor_to_connect_to,
            onBackButtonPressed: () =>
                context.read<MockMonitorCubit>().goToPreviousStep(),
            isLoading: state.isStillScanning,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: state.devices
                    .map(
                      (device) => GestureDetector(
                        onTap: () =>
                            context.read<MockMonitorCubit>().selectDevice(
                              device,
                            ),
                        child: _DevicePickCard(
                          serialNumber: device.serialNumber,
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
    return PairDeviceBody(
      key: const ValueKey('foundStepSingle'),
      title: context.text.monitor_setup_found,
      asset: 'assets/illustrations/monitor/illustration_monitor_front.png',
      onBackButtonPressed: () =>
          context.read<MockMonitorCubit>().goToPreviousStep(),
      isLoading: isConnecting,
      child: SetupTextField(
        controller: _nameInputController,
        validationRule: (name) => name.isNotEmpty,
        hintText: context.text.monitor_pair_friendly_name_hint,
        textCapitalization: TextCapitalization.sentences,
        withInputField: !widget.isLaunchedToChangeWiFi,
        onSubmitted: (name) {
          context.read<MockMonitorCubit>().connectToDevice(device, name);
        },
      ),
    );
  }

  Widget _buildChargeMonitorStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('chargeMonitorStep'),
      onBackButtonPressed: widget.onNavigatedBack,
      title: context.text.monitor_setup_charge_device,
      asset: 'assets/illustrations/monitor/illustration_monitor_front.png',
      assetBottomPadding: 0,
      description: context.text.monitor_setup_charge_device_description,
      child: Column(
        children: [
          const ChargingAnimation(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.text.monitor_setup_looking_for_your_monitor),
              const SizedBox(width: 16),
              CircularLoadingBar(
                color: secondaryColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
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
    );
  }

  Widget _buildWiFiPasswordInputStep(
    BuildContext context,
    String ssid, {
    bool previouslyFailed = false,
  }) {
    return PairDeviceBody(
      key: const ValueKey('wiFiPasswordInputStep'),
      title: ssid,
      description: previouslyFailed
          ? context
              .text
              .monitor_pair_unable_to_connect_to_wifi_error_description
          : null,
      onBackButtonPressed: () =>
          context.read<MockMonitorCubit>().goToPreviousStep(),
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
    );
  }

  Widget _buildProvisioningSuccess() {
    return PairDeviceBody(
      key: const ValueKey('provisioningSuccessStep'),
      title: context.text.monitor_pair_provisioning_success_title,
      primaryButtonLabel: widget.isLaunchedToChangeWiFi
          ? context.text.monitor_pair_continue
          : context.text.monitor_pair_provisioning_success_button,
      onPrimaryButtonPressed: () => widget.onMonitorAdded?.call(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Image.asset('assets/images/monitor_setup_success.png'),
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
      onBackButtonPressed: () =>
          context.read<MockMonitorCubit>().goToPreviousStep(),
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
      onBackButtonPressed: () => context.read<MockMonitorCubit>().goToPreviousStep(),
      child: const Padding(
        padding: EdgeInsets.only(top: 24.0),
        child: WifiRadarAnimation(size: 240),
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
      onCloseButtonPressed: () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SetupProgressIndicator(step: step),
      ),
    );
  }

  Widget _buildNoiseDetectionStep(BuildContext context) {
    return Container(
      color: context.color.surfaceSecondary,
      child: PairDeviceBody(
        key: const ValueKey('noiseDetectionStep'),
        title: context.text.monitor_setup_noise_detection_title,
        description: context.text.monitor_setup_noise_detection_description,
        titleBottomPadding: 12,
        primaryButtonLabel: context.text.monitor_pair_continue,
        onPrimaryButtonPressed: () {
          context.read<MockMonitorCubit>().setNoiseDetectionLevel(
            _noiseDetectionLevel,
            _onlyBabyCries,
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: NoiseDetectionBody(
            level: _noiseDetectionLevel,
            onlyBabyCries: _onlyBabyCries,
            onLevelSelected: (l) => setState(() => _noiseDetectionLevel = l),
            onOnlyBabyCriesChanged: (v) => setState(() => _onlyBabyCries = v),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingConsentStep(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: context.color.textSecondary,
    );
    final descriptionWidget = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: bodyStyle,
        children: [
          TextSpan(
            text: context.text.monitor_pair_allow_sound_monitoring_description,
          ),
          TextSpan(
            text: context.text.privacy_policy_link,
            style: bodyStyle?.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: context.color.textSecondary,
            ),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );

    return PairDeviceBody(
      key: const ValueKey('streamingConsentStep'),
      title: context.text.monitor_pair_allow_sound_monitoring_title,
      descriptionWidget: descriptionWidget,
      primaryButtonLabel: context.text.give_consent,
      onPrimaryButtonPressed: () =>
          context.read<MockMonitorCubit>().giveStreamingConsent(),
      secondaryButtonLabel: context.text.disable,
      onSecondaryButtonPressed: () =>
          context.read<MockMonitorCubit>().refuseStreamingConsent(),
      onCloseButtonPressed: () => Navigator.of(context).pop(),
      child: const SizedBox(height: 36),
    );
  }

  String _finalConfigurationStepLabel(FinalConfigurationStep step) {
    return switch (step) {
      FinalConfigurationStep.connectingToWiFi =>
        context.text.monitor_setup_connecting_to_wifi,
      FinalConfigurationStep.provisioning =>
        context.text.monitor_setup_provisioning,
      FinalConfigurationStep.uploadingAwsCredential =>
        context.text.monitor_setup_uploading_credentials,
      FinalConfigurationStep.checkingFirmwareVersion =>
        context.text.monitor_setup_checking_firmware,
      FinalConfigurationStep.upgradingFirmware =>
        context.text.monitor_setup_upgrading_firmware,
      FinalConfigurationStep.firstFirmwareUpgradeProcessCheck =>
        context.text.monitor_setup_upgrading_firmware_first_milestone,
      FinalConfigurationStep.secondFirmwareUpgradeProcessCheck =>
        context.text.monitor_setup_upgrading_firmware_second_milestone,
      FinalConfigurationStep.finalizing =>
        context.text.monitor_setup_finalizing,
    };
  }

  @override
  void dispose() {
    _nameInputController.dispose();
    _passwordInputController.dispose();
    super.dispose();
  }
}

/// Minimal device card for multi-device selection
class _DevicePickCard extends StatelessWidget {
  final String serialNumber;

  const _DevicePickCard({required this.serialNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.color.borderSubdued),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/babymonitor_packshot.png',
            height: 140,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'S/N: $serialNumber',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.color.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Moonboon Monitor',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
