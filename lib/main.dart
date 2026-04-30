import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'common/device_radius.dart';
import 'common/firmware_update_sheet.dart';
import 'common/modal_sheet.dart';
import 'common/monitor_troubleshoot_page.dart';
import 'mock/mock_monitor_cubit.dart';
import 'setup_flow/bloc/setup_error_type.dart';
import 'setup_flow/monitor_provisioning_page.dart';
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
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final colors = _isDark ? ThemeColors.darkVariantC : ThemeColors.light;
    return MaterialApp(
      title: 'Moonboon Monitor Setup',
      debugShowCheckedModeBanner: false,
      theme: buildThemeWithColors(colors, _isDark ? Brightness.dark : Brightness.light),
      themeMode: ThemeMode.light,
      home: _LauncherPage(
        isDark: _isDark,
        onToggleDark: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}

// ── Launcher ──────────────────────────────────────────────────────────────────

class _LauncherPage extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleDark;

  const _LauncherPage({required this.isDark, required this.onToggleDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moonboon',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Monitor Setup',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.color.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onToggleDark,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.color.textPrimary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 20,
                        color: context.color.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Setup flow ───────────────────────────────────────────────
              _SectionLabel(label: 'Setup flow'),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Full monitor flow',
                subtitle: 'Charge → Search → Found → WiFi → Provisioning → Consent → Done',
                onTap: () => _openMonitorFlow(context),
              ),

              const SizedBox(height: 32),

              // ── Setup steps ──────────────────────────────────────────────
              _SectionLabel(label: 'Setup steps'),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Charge device',
                subtitle: 'Plug in and power on the monitor before connecting',
                onTap: () => _openStep(context, (c) => c.showChargeStep()),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Searching for monitor',
                subtitle: 'Bluetooth scan — auto-advances to Found after 2.5 s',
                onTap: () => _openStep(context, (c) => c.showSearchingStep()),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Monitor found',
                subtitle: 'Name entry — tap Connect to continue',
                onTap: () => _openStep(context, (c) => c.showFoundStep()),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'WiFi networks',
                subtitle: 'Network list — tap a network to enter password',
                onTap: () => _openStep(context, (c) => c.showWifiListStep()),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'WiFi password',
                subtitle: 'Password input for "Home WiFi"',
                onTap: () => _openStep(context, (c) => c.showWifiPasswordStep()),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Provisioning',
                subtitle: 'Progress states — connecting, uploading, firmware check',
                onTap: () => _openStep(context, (c) => c.showProvisioningStep()),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Sound monitoring consent',
                subtitle: 'Enable or disable sound monitoring',
                onTap: () => _openStep(context, (c) => c.showConsentStep()),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Noise detection',
                subtitle: 'Sensitivity slider — set detection level',
                onTap: () => _openStep(context, (c) => c.showNoiseDetectionStep()),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Streaming consent',
                subtitle: 'Allow audio streaming for remote monitoring',
                onTap: () => _openStep(context, (c) => c.showStreamingConsentStep()),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Welcome gift',
                subtitle: 'Moonboon Plus onboarding screen',
                onTap: () => _openStep(context, (c) => c.showWelcomeGiftStep()),
              ),

              const SizedBox(height: 32),

              // ── Modals & states ──────────────────────────────────────────
              _SectionLabel(label: 'Modals & States'),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Firmware update',
                subtitle: 'Sheet — update now vs. continue without updating',
                onTap: () => showFirmwareUpdateSheet(
                  context,
                  onUpdate: () {},
                  onContinueWithout: () {},
                ),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Something went wrong',
                subtitle: 'Error state with retry + troubleshoot link',
                onTap: () => _openMonitorFlow(context, simulateError: true),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Troubleshoot guide',
                subtitle: 'Full-screen guide — charging, Bluetooth, WiFi, reset',
                onTap: () => openMonitorTroubleshootPage(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the full connected monitor provisioning flow.
  void _openMonitorFlow(BuildContext context, {bool simulateError = false}) {
    _openSetupSheet(
      context,
      child: (ctx) => BlocProvider(
        create: (_) {
          final cubit = MockMonitorCubit();
          if (simulateError) {
            cubit.simulateError(SetupErrorType.monitorNotFound);
          } else {
            cubit.checkCurrentUser();
          }
          return cubit;
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height - 60),
          child: const MonitorProvisioningPage(),
        ),
      ),
    );
  }

  /// Opens the monitor setup sheet with the cubit jumped to a specific step.
  void _openStep(BuildContext context, void Function(MockMonitorCubit) jumpTo) {
    _openSetupSheet(
      context,
      child: (ctx) => BlocProvider(
        create: (_) {
          final cubit = MockMonitorCubit();
          jumpTo(cubit);
          return cubit;
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height - 60),
          child: const MonitorProvisioningPage(),
        ),
      ),
    );
  }

  void _openSetupSheet(BuildContext context, {required Widget Function(BuildContext) child}) {
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
            child: child(ctx),
          ),
        );
      },
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: context.color.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Flow tile ─────────────────────────────────────────────────────────────────

class _FlowTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _FlowTile({required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: context.color.surfaceTertiary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.color.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: context.color.textQuaternary,
            ),
          ],
        ),
      ),
    );
  }
}
