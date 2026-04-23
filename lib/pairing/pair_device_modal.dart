import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../common/circular_loading_bar.dart';
import '../setup_flow/setup_text_field.dart';
import '../common/pair_device_body.dart';
import '../common/setup_sheet_body.dart';
import '../setup_flow/bloc/final_configuration_step.dart';
import '../setup_flow/component/setup_progress_indicator.dart';
import '../setup_flow/component/wifi_radar_animation.dart';
import '../mock/mock_motor_cubit.dart';
import '../strings/app_strings.dart';
import '../theme/theme_colors.dart';
import 'bloc/pair_device_state.dart';
import 'component/motor_video_animation.dart';
import 'motor_type.dart';

class PairDeviceModal extends StatefulWidget {
  final MotorType motorType;

  const PairDeviceModal({super.key, required this.motorType});

  @override
  State<PairDeviceModal> createState() => _PairDeviceModalState();
}

class _PairDeviceModalState extends State<PairDeviceModal> {
  double _swipeStartX = 9999;
  PairDeviceState? _currentState;
  final _nameController = SetupTextController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int? _stepFor(PairDeviceState state) => switch (state) {
    PairDeviceStatePowerUp() => 1,
    PairDeviceStateTurnOn() => 2,
    PairDeviceStateTurnOnBluetooth() => 3,
    PairDeviceStateBluetoothPermission() => 3,
    PairDeviceStateBluetoothPermissionDenied() => 3,
    PairDeviceStateScanningStep() => 4,
    PairDeviceStateFound() => 4,
    PairDeviceStateLoading() => 5,
    PairDeviceStateActivating() => 5,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MockMotorCubit, PairDeviceState>(
      builder: (context, state) {
        _currentState = state;
        final step = _stepFor(state);
        final useSurfaceSecondaryBg = state is PairDeviceStateGetNotified;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (d) => _swipeStartX = d.globalPosition.dx,
          onHorizontalDragEnd: (d) {
            if (_swipeStartX > 44) return;
            if (d.velocity.pixelsPerSecond.dx <= 500) return;
            final s = _currentState;
            if (s is PairDeviceStatePowerUp) {
              Navigator.of(context).pop();
            } else {
              context.read<MockMotorCubit>().goToPreviousStep();
            }
          },
          child: SetupSheetBody(
            step: step,
            totalSteps: 5,
            backgroundColor: useSurfaceSecondaryBg
                ? context.color.surfaceSecondary
                : null,
            child: _buildContentForState(context, state),
          ),
        );
      },
    );
  }

  Widget _buildContentForState(BuildContext context, PairDeviceState state) =>
      switch (state) {
        PairDeviceStatePowerUp() => _buildPowerUpStep(context),
        PairDeviceStateTurnOn() => _buildTurnOnStep(context),
        PairDeviceStateTurnOnBluetooth() => _buildTurnOnBluetoothStep(context),
        PairDeviceStateBluetoothPermission() => _buildBluetoothPermissionStep(context),
        PairDeviceStateBluetoothPermissionDenied() => _buildBluetoothPermissionDeniedStep(context),
        PairDeviceStateEnterPairingMode() => _buildScanningStep(context),
        PairDeviceStateScanningStep() => _buildScanningStep(context),
        PairDeviceStateLoading() => _buildConnectingStep(context),
        PairDeviceStateActivating s => _buildActivatingStep(context, s.deviceName, s.progress),
        PairDeviceStateFound s => s.deviceNames.length == 1
            ? _buildSingleFoundStep(context, s.deviceNames.first)
            : _buildMultipleFoundStep(context, s.deviceNames),
        PairDeviceStatePaired() => _buildPairedStep(context),
        PairDeviceStateGetNotified() => _buildGetNotifiedStep(context),
        PairDeviceStateError s => _buildErrorStep(context, s.message),
        PairDeviceStateTimedOut() => _buildTimedOutStep(context),
        PairDeviceStateInvalidBond s => _buildInvalidBondStep(context, s.address),
      };

  // ── Steps ─────────────────────────────────────────────────────────────────

  // ── Per-type video asset paths ────────────────────────────────────────────

  String _powerUpVideo(bool isDark) => switch (widget.motorType) {
    MotorType.basic   => isDark ? 'assets/videos/motor_basic_power_up_dark.mov' : 'assets/videos/motor_basic_power_up.mov',
    MotorType.premium => isDark ? 'assets/videos/motor_power_up_dark.mov' : 'assets/videos/motor_power_up.mov',
  };

  String _turnOnVideo(bool isDark) => switch (widget.motorType) {
    MotorType.basic   => isDark ? 'assets/videos/motor_basic_turn_on_dark.mov' : 'assets/videos/motor_basic_turn_on.mov',
    MotorType.premium => isDark ? 'assets/videos/motor_turn_on_dark.mov' : 'assets/videos/motor_turn_on.mov',
  };

  String _bluetoothVideo(bool isDark) => switch (widget.motorType) {
    MotorType.basic   => isDark ? 'assets/videos/motor_basic_turn_on_bluetooth_dark.mov' : 'assets/videos/motor_basic_turn_on_bluetooth.mov',
    MotorType.premium => isDark ? 'assets/videos/motor_turn_on_bluetooth_dark.mov' : 'assets/videos/motor_turn_on_bluetooth.mov',
  };

  // ── Step builders ─────────────────────────────────────────────────────────

  Widget _buildPowerUpStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PairDeviceBody(
      key: const ValueKey('powerUp'),
      title: context.text.motor_pairing_power_up,
      description: context.text.motor_pairing_power_up_description,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: MotorVideoAnimation(assetPath: _powerUpVideo(isDark)),
      ),
    );
  }

  Widget _buildTurnOnStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PairDeviceBody(
      key: const ValueKey('turnOn'),
      title: context.text.motor_pairing_turn_on,
      description: widget.motorType == MotorType.premium
          ? context.text.motor_pairing_turn_on_knobs
          : context.text.motor_pairing_turn_on_power_button,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: MotorVideoAnimation(assetPath: _turnOnVideo(isDark)),
      ),
    );
  }

  Widget _buildTurnOnBluetoothStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PairDeviceBody(
      key: const ValueKey('turnOnBluetooth'),
      title: context.text.motor_pairing_turn_on_bluetooth,
      description: context.text.motor_pairing_press_bluetooth_button,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: MotorVideoAnimation(assetPath: _bluetoothVideo(isDark), loop: false),
      ),
    );
  }

  String get _pairingImage => switch (widget.motorType) {
    MotorType.basic   => 'assets/images/motor_basic_pairing.png',
    MotorType.premium => 'assets/images/motor_pairing.png',
  };

  Widget _buildScanningStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('scanning'),
      title: context.text.motor_pairing_looking,
      child: WifiRadarAnimation(
        size: 270,
        imageAsset: _pairingImage,
      ),
    );
  }

  Widget _buildConnectingStep(BuildContext context) {
    final motorImage = switch (widget.motorType) {
      MotorType.basic => 'assets/images/motor_connect_packshot.png',
      MotorType.premium => 'assets/images/motor_premium_packshot.png',
    };
    return PairDeviceBody(
      key: const ValueKey('connecting'),
      title: context.text.device_connection_state_connecting,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              CircularLoadingBar(
                color: context.color.brandPrimary.withValues(alpha: 0.35),
                size: 240,
                strokeWidth: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: Image.asset(motorImage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.text.motor_pairing_activating,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.color.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothPermissionStep(BuildContext context) {
    return _BluetoothPermissionStep(
      key: const ValueKey('bluetoothPermission'),
      pairingImageAsset: _pairingImage,
      onGranted: () => context.read<MockMotorCubit>().bluetoothPermissionGranted(),
      onDenied: () => context.read<MockMotorCubit>().bluetoothPermissionDenied(),
    );
  }

  Widget _buildBluetoothPermissionDeniedStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('bluetoothPermissionDenied'),
      title: context.text.allow_bluetooth_title,
      description: context.text.allow_bluetooth_description,
      primaryButtonLabel: context.text.open_settings,
      secondaryButtonLabel: context.text.try_again,
      onPrimaryButtonPressed: () {
        // no-op in playground
      },
      onSecondaryButtonPressed: () => context.read<MockMotorCubit>().goToPreviousStep(),
      child: const SizedBox(height: 24),
    );
  }

  Widget _buildSingleFoundStep(BuildContext context, String deviceName) {
    return PairDeviceBody(
      key: const ValueKey('found'),
      title: 'Motor found',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(_pairingImage, height: 200),
            ),
          ),
          SetupTextField(
            controller: _nameController,
            validationRule: (name) => name.trim().isNotEmpty,
            hintText: 'Name your device',
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (name) {
              FocusScope.of(context).unfocus();
              context.read<MockMotorCubit>().connectToDevice(
                deviceName,
                friendlyName: name.trim(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleFoundStep(BuildContext context, List<String> devices) {
    final motorImage = switch (widget.motorType) {
      MotorType.basic   => 'assets/images/motor_connect_packshot.png',
      MotorType.premium => 'assets/images/motor_premium_packshot.png',
    };
    const mockSerials = ['MB-1042', 'MB-2391'];
    return PairDeviceBody(
      key: const ValueKey('foundMultiple'),
      title: 'Motors found',
      description: 'Select the motor you want to connect to.',
      titleBottomPadding: 8,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(devices.length, (i) {
            return _MotorPickCard(
              deviceName: devices[i],
              motorImage: motorImage,
              serialNumber: i < mockSerials.length ? mockSerials[i] : 'MB-000$i',
              onConnect: () => context.read<MockMotorCubit>().connectToDevice(
                devices[i],
                friendlyName: devices[i],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActivatingStep(
    BuildContext context,
    String deviceName,
    double progress,
  ) {
    return PairDeviceBody(
      key: const ValueKey('activating'),
      title: deviceName,
      child: SetupProgressIndicator(
        step: _progressToStep(progress),
        imageAsset: _pairingImage,
      ),
    );
  }

  FinalConfigurationStep _progressToStep(double progress) {
    if (progress <= 0.08) return FinalConfigurationStep.connectingToWiFi;
    if (progress <= 0.28) return FinalConfigurationStep.provisioning;
    if (progress <= 0.50) return FinalConfigurationStep.uploadingAwsCredential;
    if (progress <= 0.72) return FinalConfigurationStep.checkingFirmwareVersion;
    return FinalConfigurationStep.finalizing;
  }

  Widget _buildPairedStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final successImage = switch (widget.motorType) {
      MotorType.basic   => isDark ? 'assets/images/motor_basic_success_dark.png' : 'assets/images/motor_basic_success_light.png',
      MotorType.premium => isDark ? 'assets/images/motor_success_dark.png' : 'assets/images/motor_success_light.png',
    };
    return PairDeviceBody(
      key: const ValueKey('paired'),
      title: 'Your motor is ready\nto bounce!',
      primaryButtonLabel: 'Start bouncing',
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().goToGetNotifiedStep(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.asset(
          successImage,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildGetNotifiedStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('getNotified'),
      title: context.text.get_notified_title,
      description: context.text.get_notified_description,
      primaryButtonLabel: context.text.enable_notifications,
      onPrimaryButtonPressed: () {
        context.read<MockMotorCubit>().enableNotifications();
        Navigator.of(context).pop();
      },
      secondaryButtonLabel: context.text.get_notified_secondary_cta,
      onSecondaryButtonPressed: () => Navigator.of(context).pop(),
    );
  }

  // ── Error states ───────────────────────────────────────────────────────────

  Widget _buildErrorStep(BuildContext context, String message) {
    return PairDeviceErrorBody(
      key: const ValueKey('error'),
      title: context.text.pairing_error_could_not_start_scanning_title,
      description: message,
      primaryButtonLabel: context.text.try_again,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
    );
  }

  Widget _buildTimedOutStep(BuildContext context) {
    return PairDeviceErrorBody(
      key: const ValueKey('timedOut'),
      title: context.text.pairing_error_could_not_start_scanning_title,
      description: 'The scan timed out. Make sure the motor is in pairing mode.',
      primaryButtonLabel: context.text.try_again,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
    );
  }

  Widget _buildInvalidBondStep(BuildContext context, String address) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String asset = switch (widget.motorType) {
      MotorType.basic => isDark
          ? 'assets/illustrations/illustration_pairing_step5_dark.svg'
          : 'assets/illustrations/illustration_pairing_step5.svg',
      MotorType.premium => isDark
          ? 'assets/illustrations/illustration_pairing_bluetooth_premium_dark.svg'
          : 'assets/illustrations/illustration_pairing_bluetooth_premium_light.svg',
    };
    return PairDeviceBody(
      key: const ValueKey('invalidBond'),
      title: context.text.pairing_onboarding_flow_fifth_step_title,
      asset: asset,
      description: context.text.press_button_description,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().connectToDevice(address),
    );
  }
}

// ── Bluetooth permission dialog step ──────────────────────────────────────────

class _BluetoothPermissionStep extends StatefulWidget {
  final String pairingImageAsset;
  final VoidCallback onGranted;
  final VoidCallback onDenied;

  const _BluetoothPermissionStep({
    super.key,
    required this.pairingImageAsset,
    required this.onGranted,
    required this.onDenied,
  });

  @override
  State<_BluetoothPermissionStep> createState() => _BluetoothPermissionStepState();
}

class _BluetoothPermissionStepState extends State<_BluetoothPermissionStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showPermissionDialog();
    });
  }

  Future<void> _showPermissionDialog() async {
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('"Moonboon" Would Like to Use Bluetooth'),
        content: const Text(
          'Moonboon uses Bluetooth to connect to and control your motor.',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDenied();
            },
            child: const Text("Don't Allow"),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onGranted();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('bluetoothPermissionBg'),
      title: context.text.motor_pairing_looking,
      child: WifiRadarAnimation(
        size: 270,
        imageAsset: widget.pairingImageAsset,
      ),
    );
  }
}

// ── Motor pick card (multiple-found picker) ───────────────────────────────────

class _MotorPickCard extends StatelessWidget {
  final String deviceName;
  final String motorImage;
  final String serialNumber;
  final VoidCallback onConnect;

  static const double _cardWidth = 200;

  const _MotorPickCard({
    required this.deviceName,
    required this.motorImage,
    required this.serialNumber,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.color.surfaceSecondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area — rotated for visual flair, clipped by container
          SizedBox(
            height: 160,
            child: OverflowBox(
              maxWidth: _cardWidth + 60,
              maxHeight: 220,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: 0.52, // ~30°
                child: Image.asset(motorImage, height: 180),
              ),
            ),
          ),
          // Info area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.text.serial_number,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.color.brandPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  serialNumber,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.color.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onConnect,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: context.color.surfaceTertiary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.text.connect,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

