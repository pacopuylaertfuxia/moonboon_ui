import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'mock/mock_monitor_cubit.dart';
import 'mock_screens/mock_monitor_settings_page.dart';
import 'mock_screens/mock_monitor_stream_page.dart';
import 'mock_screens/mock_settings_page.dart';
import 'mock_screens/mock_nap_track_page.dart';
import 'mock_screens/mock_devices_page.dart';
import 'mock_screens/mock_motor_details_page.dart';
import 'mock_screens/mock_motor_stream_page.dart';
import 'mock/mock_motor_cubit.dart';
import 'pairing/component/motor_video_animation.dart';
import 'pairing/motor_type.dart';
import 'pairing/pair_device_modal.dart';
import 'setup_flow/bloc/final_configuration_step.dart';
import 'setup_flow/component/noise_detection_body.dart';
import 'setup_flow/component/sound_monitoring_consent_body.dart';
import 'setup_flow/component/streaming_consent_body.dart';
import 'setup_flow/component/setup_progress_indicator.dart';
import 'setup_flow/component/wifi_radar_animation.dart';
import 'setup_flow/monitor_provisioning_page.dart';
import 'common/button.dart';
import 'common/device_radius.dart';
import 'common/modal_sheet.dart';
import 'common/pair_device_body.dart';
import 'live_activity/live_activity_cubit.dart';
import 'live_activity/live_activity_playground.dart';
import 'live_activity/live_activity_service.dart';
import 'live_activity/modular_activity_playground.dart';
import 'live_activity/di_animation_demo.dart';
import 'live_activity/di_live_demo.dart';
import 'live_activity/prototype_conversion_page.dart';
import 'live_activity/warm_monitor_demo.dart';
import 'live_activity/variant10_demo.dart';
import 'live_activity/variant11_demo.dart';
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

enum _ThemeVariant { light, dark, darkPlus, darkOriginal }

extension _ThemeVariantLabel on _ThemeVariant {
  String get label => switch (this) {
        _ThemeVariant.light        => 'Light',
        _ThemeVariant.dark         => 'Dark',
        _ThemeVariant.darkPlus     => 'Dark +',
        _ThemeVariant.darkOriginal => 'Dark OG',
      };
  ThemeColors get colors => switch (this) {
        _ThemeVariant.light        => ThemeColors.light,
        _ThemeVariant.dark         => ThemeColors.dark,
        _ThemeVariant.darkPlus     => ThemeColors.darkVariantC,
        _ThemeVariant.darkOriginal => ThemeColors.darkOriginal,
      };
  Brightness get brightness => this == _ThemeVariant.light ? Brightness.light : Brightness.dark;
}

class _MoonboonUIAppState extends State<MoonboonUIApp> {
  _ThemeVariant _variant = _ThemeVariant.light;

  void _cycleVariant() => setState(() {
        _variant = _ThemeVariant.values[(_variant.index + 1) % _ThemeVariant.values.length];
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moonboon UI',
      debugShowCheckedModeBanner: false,
      theme: buildThemeWithColors(_variant.colors, _variant.brightness),
      themeMode: ThemeMode.light, // always use theme, not darkTheme
      home: _PlaygroundPage(
        variantLabel: _variant.label,
        isDark: _variant != _ThemeVariant.light,
        onCycleVariant: _cycleVariant,
      ),
    );
  }
}

// ── Playground ─────────────────────────────────────────────────────────────────

class _PlaygroundPage extends StatefulWidget {
  final String variantLabel;
  final bool isDark;
  final VoidCallback onCycleVariant;
  const _PlaygroundPage({
    required this.variantLabel,
    required this.isDark,
    required this.onCycleVariant,
  });
  @override
  State<_PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<_PlaygroundPage> {
  bool _hideListBehindSheet = false;

  Future<void> _show(
    BuildContext context, {
    required Widget child,
    ModalSheetBackground background = ModalSheetBackground.white,
    bool hasPadding = true,
  }) async {
    await ModalSheet.show(
      context: context,
      background: background,
      hasPadding: hasPadding,
      duration: Duration.zero,
      child: child,
    );
  }

  void _showModeSelectionSheet(BuildContext context) {
    bool showHeader = false;
    NoiseDetectionLevel level = NoiseDetectionLevel.medium;
    bool onlyBabyCries = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: isDark
          ? Colors.black.withValues(alpha: 0.75)
          : Colors.black.withValues(alpha: 0.38),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModeSelectionVariantToggle(
              showHeader: showHeader,
              onChanged: (v) => setSheetState(() => showHeader = v),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              child: ModalSheet(
                hasPadding: false,
                duration: Duration.zero,
                background: ModalSheetBackground.cream,
                child: ModeSelectionBody(
                  level: level,
                  onlyBabyCries: onlyBabyCries,
                  title: showHeader ? 'Mode selection' : null,
                  subtitle: showHeader
                      ? 'Choose how sensitive the monitor should be to sounds.'
                      : null,
                  onLevelSelected: (l) => setSheetState(() => level = l),
                  onOnlyBabyCriesChanged: (v) => setSheetState(() => onlyBabyCries = v),
                  onContinue: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
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
              GestureDetector(
                onTap: widget.onCycleVariant,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.color.surfaceTertiary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isDark ? Icons.dark_mode : Icons.light_mode,
                        size: 14,
                        color: context.color.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.variantLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.color.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── Setup flow ──────────────────────────────────────────
                  _CollapsibleSection(
                    title: 'Setup Flow',
                    initiallyExpanded: false,
                    children: [
                      _DemoTile(
                        number: '▶',
                        title: 'Complete setup flow',
                        subtitle: 'All steps in sequence — charge · name · WiFi · config · consent · noise',
                        onTap: () => _openMonitorSetupFlow(context),
                      ),
                      _DemoTile(
                        number: '1',
                        title: 'Charge monitor step',
                        subtitle: 'First step — power up video',
                        onTap: () => _show(context,
                          hasPadding: false,
                          child: const _WithStepper(step: 1, totalSteps: 5, child: _ChargingSheet())),
                      ),
                      _DemoTile(
                        number: '1b',
                        title: 'Searching for monitor',
                        subtitle: 'Radar animation while scanning for Bluetooth device',
                        onTap: () => _show(context,
                          hasPadding: false,
                          child: const _WithStepper(step: 2, totalSteps: 5, child: _SearchingSheet())),
                      ),
                      _DemoTile(
                        number: '2',
                        title: 'WiFi radar scanning',
                        subtitle: 'Pulse-ring radar animation while searching for networks',
                        onTap: () => _show(context,
                          hasPadding: false,
                          child: const _WithStepper(step: 3, totalSteps: 5, child: _RadarSheet())),
                      ),
                      _DemoTile(
                        number: '3',
                        title: 'Final configuration step',
                        subtitle: 'Progress ring · baby-themed typewriter messages · cycles steps',
                        onTap: () async {
                          setState(() => _hideListBehindSheet = true);
                          await _show(context,
                            hasPadding: false,
                            child: const _WithStepper(step: 4, totalSteps: 5, child: _FinalConfigSheet()));
                          if (mounted) setState(() => _hideListBehindSheet = false);
                        },
                      ),
                      _DemoTile(
                        number: '4',
                        title: 'Allow sound monitoring',
                        subtitle: 'Consent step — give consent or disable sound monitoring',
                        onTap: () => _show(context,
                          hasPadding: false,
                          child: const _SoundMonitoringConsentSheet()),
                      ),
                      _DemoTile(
                        number: '5',
                        title: 'Noise detection step',
                        subtitle: 'Redesigned level picker with AI badge · fully interactive',
                        onTap: () => _showModeSelectionSheet(context),
                      ),
                      _DemoTile(
                        number: '6',
                        title: 'Your device is ready to stream',
                        subtitle: 'Full-bleed packshot · "Start streaming" CTA',
                        onTap: () => _show(context,
                          hasPadding: false,
                          child: const _StreamingConsentSheet()),
                      ),
                      _DemoTile(
                        number: '7',
                        title: 'Error state',
                        subtitle: 'Error body with "troubleshoot page" link',
                        onTap: () => _show(context, hasPadding: false, child: const _ErrorSheet()),
                      ),
                      _DemoTile(
                        number: '8',
                        title: 'Troubleshoot page',
                        subtitle: 'Full-screen — 4 step cards + contact support link',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const _TroubleshootPage())),
                      ),
                      _DemoTile(
                        number: '9',
                        title: 'Fluid sheet resize',
                        subtitle: 'Sheet height animates smoothly between steps',
                        onTap: () => _show(context,
                          hasPadding: false,
                          child: const _FluidResizeSheet()),
                      ),
                    ],
                  ),

                  // ── Devices tab ─────────────────────────────────────────
                  _CollapsibleSection(
                    title: 'Devices Tab',
                    children: [
                      _DemoTile(
                        number: '📱',
                        title: 'Devices — Design Vision',
                        subtitle: 'Full-bleed product cards · motor running state · mode picker',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MockDevicesPage())),
                      ),
                    ],
                  ),

                  // ── Monitor stream ──────────────────────────────────────
                  _CollapsibleSection(
                    title: 'Monitor Stream',
                    children: [
                      _DemoTile(
                        number: '📡',
                        title: 'Monitor stream page',
                        subtitle: 'Full page — app bar · telemetry · 16:9 video · notification feed',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MockMonitorStreamPage())),
                      ),
                      _DemoTile(
                        number: '⚙️',
                        title: 'Monitor settings',
                        subtitle: 'Noise detection · toggles · network · support · remove',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MockMonitorSettingsPage())),
                      ),
                      _DemoTile(
                        number: '👤',
                        title: 'Profile / Settings',
                        subtitle: 'Profile card · 2-col grid tiles · version label',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MockSettingsPage())),
                      ),
                    ],
                  ),

                  // ── Live Activities ─────────────────────────────────────
                  _CollapsibleSection(
                    title: 'Live Activities',
                    children: [
                      _DemoTile(
                        number: '👶',
                        title: 'Variant 11 — Lock Screen Pill',
                        subtitle: 'New Figma design — moonboon wordmark · camera rings · waveform · baby face',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Variant11Demo()),
                        ),
                      ),
                      _DemoTile(
                        number: '🌙',
                        title: 'Variant 10',
                        subtitle: 'Figma-faithful — moon pill · [name] is Quiet/Crying · KeplerStd · warm lock screen',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Variant10Demo()),
                        ),
                      ),
                      _DemoTile(
                        number: '🌿',
                        title: 'Warm Monitor (V9)',
                        subtitle: 'New design — cream bg · moon pill · waveform strip · stat cards',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WarmMonitorDemo()),
                        ),
                      ),
                      _DemoTile(
                        number: '⭐',
                        title: 'Prototype Conversion',
                        subtitle: 'Monitor A · 5s auto-expand · image rotation · cry detection',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrototypeConversionPage(),
                          ),
                        ),
                      ),
                      _DemoTile(
                        number: '⬤',
                        title: 'Activity Playground',
                        subtitle: '6 designs · compare on Lock Screen & Dynamic Island simultaneously',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => LiveActivityCubit(LiveActivityService()),
                              child: const LiveActivityPlayground(),
                            ),
                          ),
                        ),
                      ),
                      _DemoTile(
                        number: '🧩',
                        title: 'Modular Activity',
                        subtitle: 'Motor · Monitor · Baby status · Temp · Humidity · Battery · WiFi',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ModularActivityPlayground()),
                        ),
                      ),
                      _DemoTile(
                        number: '🏝️',
                        title: 'Dynamic Island Animation',
                        subtitle: 'Compact → expand → Monitoring → Quiet → Crying sequence',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DiAnimationDemo()),
                        ),
                      ),
                      _DemoTile(
                        number: '🔴',
                        title: 'Dynamic Island — Live',
                        subtitle: 'Runs the sequence on the real Dynamic Island',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DiLiveDemo()),
                        ),
                      ),
                    ],
                  ),

                  // ── Nap tracking ─────────────────────────────────────────
                  _CollapsibleSection(
                    title: 'Nap Tracking',
                    children: [
                      _DemoTile(
                        number: '🌙',
                        title: 'Nap tracking screen',
                        subtitle: 'Tab screen — date nav · active timer · nap list',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MockNapTrackPage())),
                      ),
                    ],
                  ),

                  // ── Motor ───────────────────────────────────────────────
                  _CollapsibleSection(
                    title: 'Motor Setup',
                    children: [
                      _DemoTile(
                        number: '→',
                        title: 'Motor stream screen',
                        subtitle: 'Timer · tempo · start/stop',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MockMotorStreamPage()),
                        ),
                      ),
                      _DemoTile(
                        number: '→',
                        title: 'Basic — full pairing flow',
                        subtitle: 'Power up → Turn on → BT → Scan → Paired',
                        onTap: () => _openMotorFlow(context, MotorType.basic),
                      ),
                      _DemoTile(
                        number: '→',
                        title: 'Premium — full pairing flow',
                        subtitle: 'Composite power up → Knobs → BT spotlight → Scan',
                        onTap: () => _openMotorFlow(context, MotorType.premium),
                      ),
                    ],
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
      builder: (ctx) {
        final keyboardUp = MediaQuery.of(ctx).viewInsets.bottom > 0;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(
            left: keyboardUp ? 0 : 6,
            right: keyboardUp ? 0 : 6,
            top: keyboardUp ? 0 : 6,
            bottom: keyboardUp ? 0 : 6,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: keyboardUp
                  ? const BorderRadius.vertical(top: Radius.circular(32))
                  : BorderRadius.only(
                      topLeft: const Radius.circular(32),
                      topRight: const Radius.circular(32),
                      bottomLeft: Radius.circular(br),
                      bottomRight: Radius.circular(br),
                    ),
              color: getModalSheetBackgroundColor(ctx, ModalSheetBackground.white),
            ),
            child: BlocProvider(
              create: (_) => MockMonitorCubit()..checkCurrentUser(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height - 60,
                ),
                child: MonitorProvisioningPage(
                  onMonitorAdded: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openMotorFlow(BuildContext context, MotorType motorType) {
    final br = DeviceRadius.instance.bottomSheetRadius;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (ctx) {
        final keyboardUp = MediaQuery.of(ctx).viewInsets.bottom > 0;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(
            left: keyboardUp ? 0 : 6,
            right: keyboardUp ? 0 : 6,
            top: keyboardUp ? 0 : 6,
            bottom: keyboardUp ? 0 : 6,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: keyboardUp
                  ? const BorderRadius.vertical(top: Radius.circular(32))
                  : BorderRadius.only(
                      topLeft: const Radius.circular(32),
                      topRight: const Radius.circular(32),
                      bottomLeft: Radius.circular(br),
                      bottomRight: Radius.circular(br),
                    ),
              color: getModalSheetBackgroundColor(ctx, ModalSheetBackground.white),
            ),
            child: BlocProvider(
              create: (_) => MockMotorCubit(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height - 60,
                ),
                child: PairDeviceModal(motorType: motorType),
              ),
            ),
          ),
        );
      },
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

// ── Collapsible section ────────────────────────────────────────────────────────

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  const _CollapsibleSection({
    required this.title,
    required this.children,
    this.initiallyExpanded = true,
  });
  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Text(
                  widget.title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.color.textTertiary,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _expanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: context.color.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Items ────────────────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    ...widget.children,
                    const SizedBox(height: 8),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Shared tile ────────────────────────────────────────────────────────────────

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
          SvgPicture.asset('assets/icons/utility/chevron_right.svg',
            colorFilter: ColorFilter.mode(context.color.textTertiary, BlendMode.srcIn),
            width: 18, height: 18),
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
      description: 'Keep the monitor plugged in throughout the entire setup process.',
      primaryButtonLabel: 'Next',
      onPrimaryButtonPressed: () {},
      child: const MotorVideoAnimation(
        assetPath: 'assets/videos/monitor_power_up.mov',
      ),
    );
  }
}

class _SearchingSheet extends StatelessWidget {
  const _SearchingSheet();
  @override
  Widget build(BuildContext context) {
    return PairDeviceBody(
      title: 'Searching...',
      child: const WifiRadarAnimation(size: 270),
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
          Text('Looking for WiFi networks…', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.color.textTertiary)),
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

class _SoundMonitoringConsentSheet extends StatelessWidget {
  const _SoundMonitoringConsentSheet();
  @override
  Widget build(BuildContext context) {
    return SoundMonitoringConsentBody(
      onGiveConsent: () => Navigator.of(context).pop(),
      onDisable: () => Navigator.of(context).pop(),
    );
  }
}

class _StreamingConsentSheet extends StatelessWidget {
  const _StreamingConsentSheet();
  @override
  Widget build(BuildContext context) {
    return StreamingConsentBody(
      onContinue: () => Navigator.of(context).pop(),
    );
  }
}


class _ErrorSheet extends StatelessWidget {
  const _ErrorSheet();
  @override
  Widget build(BuildContext context) {
    return PairDeviceErrorBody(
      title: 'Something went wrong',
      description: 'Ensure your device is charging while connecting. Also, set up in an area with a strong Wi-Fi connection and keep your Bluetooth enabled.',
      primaryButtonLabel: 'Retry',
      onPrimaryButtonPressed: () => Navigator.of(context).pop(),
      onTroubleshoot: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const _TroubleshootPage()),
        );
      },
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(step.label, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: context.color.textPrimary), textAlign: TextAlign.center),
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
    final c = context.color;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/utility/chevron_left.svg',
                      colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, safeBottom + 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    // Headline + subtitle (gap:8)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: c.textSecondary,
                            ),
                            children: const [
                              TextSpan(text: 'Having '),
                              TextSpan(text: 'trouble', style: TextStyle(fontStyle: FontStyle.italic)),
                              TextSpan(text: ' setting up your monitor?'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Work through these steps one by one - most issues are fixed within the first two.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: c.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    // Cards section (gap:16)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        // Cards (gap:8)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 8,
                          children: [
                            _TroubleshootCard(
                              icon: SvgPicture.asset('assets/icons/utility/alert_mode.svg',
                                colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
                                width: 18, height: 18),
                              title: 'Make sure the monitor is charging',
                              description: 'The monitor must be plugged in throughout the entire setup. A low battery can interrupt the connection mid-process and cause it to fail.',
                            ),
                            _TroubleshootCard(
                              icon: SvgPicture.asset('assets/icons/utility/bluetooth.svg',
                                colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
                                width: 18, height: 18),
                              title: 'Enable Bluetooth and stay close',
                              description: "Bluetooth must be enabled on your phone. Stay within arm's reach of the monitor for the full duration of setup - Bluetooth range drops fast through walls.",
                            ),
                            _TroubleshootCard(
                              icon: SvgPicture.asset('assets/icons/utility/bell.svg',
                                colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
                                width: 18, height: 18),
                              title: 'Check your WiFi network',
                              description: 'The monitor only supports 2.4 GHz networks. If your router broadcasts both 2.4 GHz and 5 GHz under the same name, try connecting to the 2.4 GHz band separately. Also make sure your WiFi password is correct - it must be 8-63 characters.',
                            ),
                            _TroubleshootCard(
                              icon: SvgPicture.asset('assets/icons/utility/refresh.svg',
                                colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
                                width: 18, height: 18),
                              title: 'Reset the monitor to factory settings',
                              description: "Hold the button on the monitor for 15 seconds until the LED starts blinking white - this means it's ready to pair again. Then start the setup from the beginning.\n\nNote: this does not affect your account or other devices.",
                            ),
                          ],
                        ),
                        // Footer
                        Center(
                          child: Text.rich(
                            TextSpan(
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary),
                              children: [
                                const TextSpan(text: 'Still stuck? '),
                                TextSpan(
                                  text: 'Contact support',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: c.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TroubleshootCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;

  const _TroubleshootCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.borderNormal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: c.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
