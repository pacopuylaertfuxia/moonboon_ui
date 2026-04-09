import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/button.dart';
import '../common/circular_loading_bar.dart';
import '../common/pair_device_body.dart';
import '../mock/mock_motor_cubit.dart';
import '../strings/app_strings.dart';
import '../theme/theme_colors.dart';
import 'bloc/pair_device_state.dart';
import 'component/bluetooth_scanning_animation.dart';
import 'component/motor_turn_on_animation.dart';
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

  int? _stepFor(PairDeviceState state) => switch (state) {
    PairDeviceStatePowerUp() => 1,
    PairDeviceStateTurnOn() => 2,
    PairDeviceStateTurnOnBluetooth() => 3,
    PairDeviceStateBluetoothPermission() => 3,
    PairDeviceStateBluetoothPermissionDenied() => 3,
    PairDeviceStateEnterPairingMode() => 3,
    PairDeviceStateScanningStep() => 4,
    PairDeviceStateFound() => 4,
    PairDeviceStateLoading() => 5,
    PairDeviceStatePaired() => 6,
    PairDeviceStateGetNotified() => 6,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            color: useSurfaceSecondaryBg
                ? context.color.surfaceSecondary
                : context.color.surfacePrimary,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: step != null ? 52.0 : 0.0),
                  child: _buildContentForState(context, state),
                ),
                if (step != null)
                  Positioned(
                    bottom: 44,
                    left: 0,
                    right: 0,
                    child: Center(child: _buildStepper(context, step, 6)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepper(BuildContext context, int currentStep, int totalSteps) {
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

  Widget _buildContentForState(BuildContext context, PairDeviceState state) =>
      switch (state) {
        PairDeviceStatePowerUp() => _buildPowerUpStep(context),
        PairDeviceStateTurnOn() => _buildTurnOnStep(context),
        PairDeviceStateTurnOnBluetooth() => _buildTurnOnBluetoothStep(context),
        PairDeviceStateBluetoothPermission() => _buildBluetoothPermissionStep(context),
        PairDeviceStateBluetoothPermissionDenied() => _buildBluetoothPermissionDeniedStep(context),
        PairDeviceStateEnterPairingMode() => _buildEnterPairingModeStep(context),
        PairDeviceStateScanningStep() => _buildScanningStep(context),
        PairDeviceStateLoading() => _buildConnectingStep(context),
        PairDeviceStateFound s => _buildFoundStep(context, s.deviceNames),
        PairDeviceStatePaired() => _buildPairedStep(context),
        PairDeviceStateGetNotified() => _buildGetNotifiedStep(context),
        PairDeviceStateError s => _buildErrorStep(context, s.message),
        PairDeviceStateTimedOut() => _buildTimedOutStep(context),
        PairDeviceStateInvalidBond s => _buildInvalidBondStep(context, s.address),
      };

  // ── Steps ─────────────────────────────────────────────────────────────────

  Widget _buildPowerUpStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('powerUp'),
      title: context.text.motor_pairing_power_up,
      description: context.text.motor_pairing_power_up_description,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: widget.motorType == MotorType.premium
            ? const _PremiumPowerUpIllustration()
            : Image.asset('assets/images/motor_power_up.png', width: 257, height: 364, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildTurnOnStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('turnOn'),
      title: context.text.motor_pairing_turn_on,
      description: widget.motorType == MotorType.premium
          ? context.text.motor_pairing_turn_on_knobs
          : context.text.motor_pairing_turn_on_power_button,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: MotorTurnOnAnimation(
          key: const ValueKey('turnOnAnimation'),
          motorType: widget.motorType,
        ),
      ),
    );
  }

  Widget _buildTurnOnBluetoothStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('turnOnBluetooth'),
      title: context.text.motor_pairing_turn_on_bluetooth,
      description: context.text.motor_pairing_press_bluetooth_button,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
      child: const Padding(
        padding: EdgeInsets.only(top: 8),
        child: _PremiumBluetoothSpotlight(),
      ),
    );
  }

  Widget _buildBluetoothPermissionStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PairDeviceBody(
      key: const ValueKey('btPermission'),
      title: context.text.allow_bluetooth_title,
      asset: isDark
          ? 'assets/illustrations/system/dark/moonboon_system_bluetooth_dark.svg'
          : 'assets/illustrations/system/light/moonboon_system_bluetooth_light.svg',
      description: context.text.allow_bluetooth_description,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
    );
  }

  Widget _buildBluetoothPermissionDeniedStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PairDeviceBody(
      key: const ValueKey('btDenied'),
      title: context.text.allow_bluetooth_title,
      asset: isDark
          ? 'assets/illustrations/system/dark/moonboon_system_bluetooth_dark.svg'
          : 'assets/illustrations/system/light/moonboon_system_bluetooth_light.svg',
      description: context.text.allow_bluetooth_description,
      primaryButtonLabel: context.text.open_settings,
      secondaryButtonLabel: context.text.try_again,
      onPrimaryButtonPressed: () => AppSettings.openAppSettings(type: AppSettingsType.settings),
      onSecondaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
    );
  }

  Widget _buildEnterPairingModeStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String asset = switch (widget.motorType) {
      MotorType.basic => isDark
          ? 'assets/illustrations/connect/dark/moonboon_connect_pairing_mode_dark.svg'
          : 'assets/illustrations/connect/light/moonboon_connect_pairing_mode_light.svg',
      MotorType.premium => isDark
          ? 'assets/illustrations/connect_premium/dark/moonboon_connect_premium_pairing_mode_dark.svg'
          : 'assets/illustrations/connect_premium/light/moonboon_connect_premium_pairing_mode_light.svg',
    };
    return PairDeviceBody(
      key: const ValueKey('enterPairingMode'),
      title: context.text.pairing_onboarding_flow_fifth_step_title,
      asset: asset,
      description: context.text.press_button_description,
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().nextStep(),
    );
  }

  Widget _buildScanningStep(BuildContext context) {
    return PairDeviceBody(
      key: const ValueKey('scanning'),
      title: context.text.motor_pairing_looking,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: BluetoothScanningAnimation(motorType: widget.motorType, size: 240),
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

  Widget _buildFoundStep(BuildContext context, List<String> devices) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String asset = switch (widget.motorType) {
      MotorType.basic => isDark
          ? 'assets/illustrations/illustration_pairing_select_basic_dark.svg'
          : 'assets/illustrations/illustration_pairing_select_basic_light.svg',
      MotorType.premium => isDark
          ? 'assets/illustrations/illustration_pairing_select_premium_dark.svg'
          : 'assets/illustrations/illustration_pairing_select_premium_light.svg',
    };

    if (devices.length == 1) {
      return PairDeviceBody(
        key: const ValueKey('found1'),
        title: devices.first,
        asset: asset,
        primaryButtonLabel: context.text.connect,
        onPrimaryButtonPressed: () => context.read<MockMotorCubit>().connectToDevice(devices.first),
      );
    }

    return PairDeviceBody(
      key: const ValueKey('foundMultiple'),
      title: context.text.motor_pairing_looking,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: devices.map((name) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _DevicePickCard(
                  name: name,
                  onPressed: () => context.read<MockMotorCubit>().connectToDevice(name),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPairedStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PairDeviceBody(
      key: const ValueKey('paired'),
      title: context.text.pairing_paired_title,
      asset: isDark
          ? 'assets/illustrations/illustration_pairing_checkmark_dark.svg'
          : 'assets/illustrations/illustration_pairing_checkmark_light.svg',
      primaryButtonLabel: context.text.next,
      onPrimaryButtonPressed: () => context.read<MockMotorCubit>().goToGetNotifiedStep(),
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

// ── Premium motor "Turn on bluetooth" illustration ────────────────────────────

class _PremiumBluetoothSpotlight extends StatelessWidget {
  const _PremiumBluetoothSpotlight();

  static const double _displayW = 207.0;
  static const double _displayH = 267.0;
  static const double _scale = 1.8;
  static const double _holeRadius = 28.0;
  static const double _overlayOpacity = 0.80;
  static const Offset _holeOffset = Offset(0.50, 0.58);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _displayW,
      height: _displayH,
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _scale,
              child: Image.asset('assets/images/motor_premium_turn_on.png', width: _displayW, height: _displayH, fit: BoxFit.contain),
            ),
            CustomPaint(
              size: const Size(_displayW, _displayH),
              painter: _SpotlightOverlayPainter(
                center: Offset(_displayW * _holeOffset.dx, _displayH * _holeOffset.dy),
                radius: _holeRadius,
                opacity: _overlayOpacity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightOverlayPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double opacity;

  const _SpotlightOverlayPainter({required this.center, required this.radius, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: opacity));
  }

  @override
  bool shouldRepaint(_SpotlightOverlayPainter old) => false;
}

// ── Premium motor "Power up" illustration ─────────────────────────────────────

class _PremiumPowerUpIllustration extends StatelessWidget {
  const _PremiumPowerUpIllustration();

  static const double _renderedW = 676.0;
  static const double _renderedH = 379.0;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        width: 257,
        height: 364,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 125,
              top: -74,
              child: Image.asset('assets/images/motor_premium_cable_wire.png', width: 6, height: 142, fit: BoxFit.fill),
            ),
            Positioned(
              left: 92,
              top: 16,
              child: SizedBox(
                width: 71,
                height: 155,
                child: ClipRect(
                  child: Transform.translate(
                    offset: const Offset(-302, -34),
                    child: Image.asset('assets/images/motor_premium_cable_top.png', width: _renderedW, height: _renderedH, fit: BoxFit.fill),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 57,
              child: SizedBox(
                width: 257,
                height: 307,
                child: ClipRect(
                  child: Transform.translate(
                    offset: const Offset(-210, -16),
                    child: Image.asset('assets/images/motor_premium_body.png', width: _renderedW, height: _renderedH, fit: BoxFit.fill),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Simple device pick card ────────────────────────────────────────────────────

class _DevicePickCard extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;

  const _DevicePickCard({required this.name, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.color.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/illustrations/illustration_pairing_select_basic_dark.svg'
                  : 'assets/illustrations/illustration_pairing_select_basic_light.svg',
              height: 80,
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.color.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Button(
              onPressed: onPressed,
              buttonLabel: Text(context.text.connect),
              variant: ButtonVariant.primary,
              size: ButtonSize.standard,
            ),
          ],
        ),
      ),
    );
  }
}
