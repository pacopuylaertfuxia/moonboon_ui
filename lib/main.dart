import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'mock/mock_monitor_cubit.dart';
import 'mock/mock_motor_cubit.dart';
import 'pairing/motor_type.dart';
import 'pairing/pair_device_modal.dart';
import 'setup_flow/bloc/final_configuration_step.dart';
import 'setup_flow/component/charging_animation.dart';
import 'setup_flow/component/noise_detection_body.dart';
import 'setup_flow/component/setup_progress_indicator.dart';
import 'setup_flow/component/wifi_radar_animation.dart';
import 'setup_flow/monitor_provisioning_page.dart';
import 'common/button.dart';
import 'common/device_radius.dart';
import 'common/modal_sheet.dart';
import 'common/pair_device_body.dart';
import 'theme/app_theme.dart';
import 'theme/theme_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceRadius.instance.init();
  runApp(const MoonboonUIApp());
}

class MoonboonUIApp extends StatefulWidget {
  const MoonboonUIApp({super.key});
  @override
  State<MoonboonUIApp> createState() => _MoonboonUIAppState();
}

class _MoonboonUIAppState extends State<MoonboonUIApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moonboon UI',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: _themeMode,
      home: _PlaygroundPage(
        themeMode: _themeMode,
        onToggleTheme: () => setState(() {
          _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        }),
      ),
    );
  }
}

// ── Playground ─────────────────────────────────────────────────────────────────

class _PlaygroundPage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  const _PlaygroundPage({required this.themeMode, required this.onToggleTheme});
  @override
  State<_PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<_PlaygroundPage> {
  bool _hideListBehindSheet = false;

  Future<void> _show(
    BuildContext context, {
    required Widget child,
    ModalSheetBackground background = ModalSheetBackground.white,
    // backgroundColor is ignored — use the background enum to control sheet color
    Color? backgroundColor,
  }) async {
    await ModalSheet.show(
      context: context,
      background: background,
      duration: Duration.zero,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hideListBehindSheet) return const SizedBox.expand();

    return Scaffold(
      backgroundColor: context.color.surfaceSecondary,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(children: [
              Text('Moonboon UI', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: widget.onToggleTheme,
              ),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Setup flow ──────────────────────────────────────────
                  const _SectionLabel('Setup flow'),
                  const SizedBox(height: 16),
                  _DemoTile(
                    number: '▶',
                    title: 'Complete setup flow',
                    subtitle: 'All steps in sequence — charge · name · WiFi · config · consent · noise',
                    onTap: () => _openMonitorSetupFlow(context),
                  ),
                  const SizedBox(height: 10),
                  _DemoTile(
                    number: '1',
                    title: 'Charge monitor step',
                    subtitle: 'First step — USB-C cable animation + scanning text',
                    onTap: () => _show(context,
                      child: const _WithStepper(step: 1, totalSteps: 5, child: _ChargingSheet())),
                  ),
                  const SizedBox(height: 10),
                  _DemoTile(
                    number: '2',
                    title: 'WiFi radar scanning',
                    subtitle: 'Pulse-ring radar animation while searching for networks',
                    onTap: () => _show(context,
                      child: const _WithStepper(step: 3, totalSteps: 5, child: _RadarSheet())),
                  ),
                  const SizedBox(height: 10),
                  _DemoTile(
                    number: '3',
                    title: 'Final configuration step',
                    subtitle: 'Progress ring · baby-themed typewriter messages · cycles steps',
                    onTap: () async {
                      setState(() => _hideListBehindSheet = true);
                      await _show(context,
                        child: const _WithStepper(step: 4, totalSteps: 5, child: _FinalConfigSheet()));
                      if (mounted) setState(() => _hideListBehindSheet = false);
                    },
                  ),
                  const SizedBox(height: 10),
                  _DemoTile(
                    number: '4',
                    title: 'Configuration complete',
                    subtitle: 'Full-bleed success illustration with floating Zzz animation',
                    onTap: () => _show(context, child: const _ConfigCompleteSheet()),
                  ),
                  const SizedBox(height: 10),
                  _DemoTile(
                    number: '5',
                    title: 'Noise detection step',
                    subtitle: 'Redesigned level picker with AI badge · fully interactive',
                    onTap: () => _show(context,
                      background: ModalSheetBackground.cream,
                      child: const _WithStepper(step: 5, totalSteps: 5, child: _NoiseDetectionSheet())),
                  ),
                  const SizedBox(height: 10),
                  _DemoTile(
                    number: '6',
                    title: 'Error state',
                    subtitle: 'Error body with "troubleshoot page" link',
                    onTap: () => _show(context, child: const _ErrorSheet()),
                  ),
                  const SizedBox(height: 10),
                  _DemoTile(
                    number: '7',
                    title: 'Troubleshoot page',
                    subtitle: 'Full-screen — 4 step cards + contact support link',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const _TroubleshootPage())),
                  ),
                  const SizedBox(height: 10),
                  _DemoTile(
                    number: '8',
                    title: 'Fluid sheet resize',
                    subtitle: 'Sheet height animates smoothly between steps',
                    onTap: () => _show(context,
                      backgroundColor: context.color.surfaceSecondary,
                      child: const _FluidResizeSheet()),
                  ),
                  const SizedBox(height: 40),

                  // ── Motor ───────────────────────────────────────────────
                  const _SectionLabel('Motor Setup'),
                  const SizedBox(height: 16),
                  _DemoTile(
                    number: '→',
                    title: 'Basic — full pairing flow',
                    subtitle: 'Power up → Turn on → BT → Scan → Paired',
                    onTap: () => _openMotorFlow(context, MotorType.basic),
                  ),
                  const SizedBox(height: 10),
                  _DemoTile(
                    number: '→',
                    title: 'Premium — full pairing flow',
                    subtitle: 'Composite power up → Knobs → BT spotlight → Scan',
                    onTap: () => _openMotorFlow(context, MotorType.premium),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _openMonitorSetupFlow(BuildContext context) {
    final br = DeviceRadius.instance.bottomSheetRadius;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(32),
            topRight: const Radius.circular(32),
            bottomLeft: Radius.circular(br),
            bottomRight: Radius.circular(br),
          ),
          child: BlocProvider(
            create: (_) => MockMonitorCubit()..checkCurrentUser(),
            child: Container(
              color: context.color.surfacePrimary,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height - 60,
              ),
              child: MonitorProvisioningPage(
                onMonitorAdded: () => Navigator.of(ctx).pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openMotorFlow(BuildContext context, MotorType motorType) {
    final br = DeviceRadius.instance.bottomSheetRadius;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(32),
            topRight: const Radius.circular(32),
            bottomLeft: Radius.circular(br),
            bottomRight: Radius.circular(br),
          ),
          child: BlocProvider(
            create: (_) => MockMotorCubit(),
            child: Container(
              color: context.color.surfacePrimary,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height - 60,
              ),
              child: PairDeviceModal(motorType: motorType),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stepper wrapper ────────────────────────────────────────────────────────────

class _WithStepper extends StatelessWidget {
  final int step;
  final int totalSteps;
  final Widget child;
  const _WithStepper({required this.step, required this.totalSteps, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(padding: const EdgeInsets.only(bottom: 52), child: child),
      Positioned(
        bottom: 44, left: 0, right: 0,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalSteps, (i) {
              final s = i + 1;
              final isCompleted = s < step;
              final isCurrent = s == step;
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
          ),
        ),
      ),
    ]);
  }
}

// ── Shared tile ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: context.color.textTertiary, letterSpacing: 1.2,
    ),
  );
}

class _DemoTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _DemoTile({required this.number, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.color.surfacePrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: context.color.brandPrimary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(number, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.color.textInverse)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.color.textTertiary)),
            ],
          )),
          Icon(Icons.chevron_right, size: 18, color: context.color.textTertiary),
        ]),
      ),
    );
  }
}

// ── Demo sheets ────────────────────────────────────────────────────────────────

class _ChargingSheet extends StatelessWidget {
  const _ChargingSheet();
  @override
  Widget build(BuildContext context) {
    return PairDeviceBody(
      title: 'Plug in your monitor',
      asset: 'assets/illustrations/monitor/illustration_monitor_front.png',
      description: 'Keep the monitor plugged in throughout the entire setup process.',
      assetBottomPadding: 0,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const ChargingAnimation(),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Looking for your monitor…', style: TextStyle(color: context.color.textTertiary, fontSize: 15)),
          const SizedBox(width: 16),
          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.color.textTertiary.withValues(alpha: 0.5))),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _RadarSheet extends StatelessWidget {
  const _RadarSheet();
  @override
  Widget build(BuildContext context) {
    return PairDeviceBody(
      title: 'Luna',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        const WifiRadarAnimation(size: 270),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Looking for WiFi networks…', style: TextStyle(color: context.color.textTertiary, fontSize: 15)),
          const SizedBox(width: 10),
          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: context.color.textTertiary.withValues(alpha: 0.5))),
        ]),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _FinalConfigSheet extends StatefulWidget {
  const _FinalConfigSheet();
  @override
  State<_FinalConfigSheet> createState() => _FinalConfigSheetState();
}
class _FinalConfigSheetState extends State<_FinalConfigSheet> {
  static const _steps = FinalConfigurationStep.values;
  int _i = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _i = (_i + 1) % _steps.length);
    });
  }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return PairDeviceBody(
      title: 'Luna',
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        child: SetupProgressIndicator(step: _steps[_i]),
      ),
    );
  }
}

class _ConfigCompleteSheet extends StatelessWidget {
  const _ConfigCompleteSheet();
  @override
  Widget build(BuildContext context) {
    return PairDeviceBody(
      title: 'All set!',
      primaryButtonLabel: 'Continue',
      onPrimaryButtonPressed: () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            child: Image.asset('assets/images/monitor_setup_success.png', width: double.infinity, fit: BoxFit.fitWidth),
          ),
          const SizedBox(height: 32),
          Text('Sweet dreams are incoming', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.color.textTertiary)),
        ]),
      ),
    );
  }
}

class _NoiseDetectionSheet extends StatefulWidget {
  const _NoiseDetectionSheet();
  @override
  State<_NoiseDetectionSheet> createState() => _NoiseDetectionSheetState();
}
class _NoiseDetectionSheetState extends State<_NoiseDetectionSheet> {
  NoiseDetectionLevel _level = NoiseDetectionLevel.medium;
  bool _onlyBabyCries = false;
  @override
  Widget build(BuildContext context) {
    return PairDeviceBody(
      title: 'Sound detection',
      description: 'Choose how sensitive the monitor should be to sounds.',
      titleBottomPadding: 12,
      primaryButtonLabel: 'Continue',
      onPrimaryButtonPressed: () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: NoiseDetectionBody(
          level: _level,
          onlyBabyCries: _onlyBabyCries,
          onLevelSelected: (l) => setState(() => _level = l),
          onOnlyBabyCriesChanged: (v) => setState(() => _onlyBabyCries = v),
        ),
      ),
    );
  }
}

class _ErrorSheet extends StatelessWidget {
  const _ErrorSheet();
  @override
  Widget build(BuildContext context) {
    return PairDeviceErrorBody(
      title: 'Could not connect to your monitor',
      description: 'Something went wrong during setup. Make sure your monitor is still charging and close to your phone, then try again.',
      primaryButtonLabel: 'Try again',
      onPrimaryButtonPressed: () => Navigator.of(context).pop(),
    );
  }
}

class _FluidResizeSheet extends StatefulWidget {
  const _FluidResizeSheet();
  @override
  State<_FluidResizeSheet> createState() => _FluidResizeSheetState();
}
class _FluidResizeSheetState extends State<_FluidResizeSheet> {
  int _step = 0;
  static const _steps = [
    (label: 'Short step', lines: 1),
    (label: 'Medium step', lines: 5),
    (label: 'Tall step', lines: 11),
  ];
  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;
    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: Alignment.bottomCenter,
      child: Padding(
        key: ValueKey(_step),
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(step.label, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: context.color.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          for (int i = 0; i < step.lines; i++)
            Container(height: 14, margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: context.color.surfaceTertiary, borderRadius: BorderRadius.circular(7))),
          const SizedBox(height: 24),
          Button(
            buttonLabel: Text(isLast ? 'Back to start' : 'Next →'),
            onPressed: () => setState(() => _step = isLast ? 0 : _step + 1),
            variant: ButtonVariant.primary,
            size: ButtonSize.lg,
          ),
        ]),
      ),
    );
  }
}

// ── Troubleshoot page ──────────────────────────────────────────────────────────

class _TroubleshootPage extends StatelessWidget {
  const _TroubleshootPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.surfaceSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.color.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom + 40,
          left: 16, right: 16,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text.rich(TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: context.color.textSecondary),
              children: const [
                TextSpan(text: 'Having '),
                TextSpan(text: 'trouble', style: TextStyle(fontStyle: FontStyle.italic)),
                TextSpan(text: ' setting up your monitor?'),
              ],
            )),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Work through these steps one by one — most issues are fixed within the first two.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.color.textTertiary, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          const _TroubleshootCard(icon: Icons.cable_outlined, title: 'Make sure the monitor is charging',
            description: 'The monitor must be plugged in throughout the entire setup. A low battery can interrupt the connection mid-process.'),
          const SizedBox(height: 12),
          const _TroubleshootCard(icon: Icons.bluetooth, title: 'Enable Bluetooth and stay close',
            description: 'Bluetooth must be enabled on your phone. Stay within arm\'s reach of the monitor for the full duration of setup.'),
          const SizedBox(height: 12),
          const _TroubleshootCard(icon: Icons.wifi, title: 'Check your WiFi network',
            description: 'The monitor only supports 2.4 GHz networks. Make sure your WiFi password is correct — it must be 8–63 characters.'),
          const SizedBox(height: 12),
          const _TroubleshootCard(icon: Icons.restart_alt, title: 'Reset the monitor to factory settings',
            description: 'Hold the button on the monitor for 15 seconds until the LED starts blinking white. Then start setup from the beginning.'),
          const SizedBox(height: 20),
          Center(child: Text.rich(TextSpan(
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.color.textTertiary),
            children: const [TextSpan(text: 'Still stuck? Contact support')],
          ))),
        ]),
      ),
    );
  }
}

class _TroubleshootCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _TroubleshootCard({required this.icon, required this.title, required this.description});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: context.color.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.color.borderNormal),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 15, color: context.color.brandPrimary),
          const SizedBox(width: 6),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.labelLarge)),
        ]),
        const SizedBox(height: 6),
        Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.color.textTertiary, height: 1.6)),
      ]),
    );
  }
}
