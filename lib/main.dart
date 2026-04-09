import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'mock/mock_monitor_cubit.dart';
import 'mock/mock_motor_cubit.dart';
import 'pairing/motor_type.dart';
import 'pairing/pair_device_modal.dart';
import 'setup_flow/bloc/setup_error_type.dart';
import 'setup_flow/monitor_provisioning_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_colors.dart';

void main() {
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
      home: PlaygroundHome(
        themeMode: _themeMode,
        onToggleTheme: () => setState(() {
          _themeMode =
              _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        }),
      ),
    );
  }
}

class PlaygroundHome extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const PlaygroundHome({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  // ── Monitor flows ──────────────────────────────────────────────────────────

  void _openMonitorFlow(
    BuildContext context,
    void Function(MockMonitorCubit) init, {
    bool isChangeWiFi = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider(
        create: (_) {
          final cubit = MockMonitorCubit();
          init(cubit);
          return cubit;
        },
        child: _SetupFlowSheet(isChangeWiFi: isChangeWiFi),
      ),
    );
  }

  // ── Motor flows ────────────────────────────────────────────────────────────

  void _openMotorFlow(
    BuildContext context,
    MotorType motorType, {
    void Function(MockMotorCubit)? init,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider(
        create: (_) {
          final cubit = MockMotorCubit();
          init?.call(cubit);
          return cubit;
        },
        child: _MotorFlowSheet(motorType: motorType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.surfaceSecondary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text('Moonboon UI', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: onToggleTheme,
                    tooltip: 'Toggle dark mode',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Monitor ──────────────────────────────────────────────
                  _SectionLabel('Monitor Setup Flow'),
                  const SizedBox(height: 12),
                  _FlowTile(
                    title: 'Full setup flow',
                    subtitle: 'Charge → Found → WiFi → Config → Success',
                    onTap: () => _openMonitorFlow(context, (c) => c.checkCurrentUser()),
                  ),
                  const SizedBox(height: 8),
                  _FlowTile(
                    title: 'Change WiFi flow',
                    subtitle: 'Skip charge, jump straight to scan',
                    onTap: () => _openMonitorFlow(
                      context,
                      (c) => c.checkCurrentUser(isLaunchedToChangeWiFi: true),
                      isChangeWiFi: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FlowTile(
                    title: 'Monitor not found',
                    subtitle: 'Timeout — nothing nearby',
                    onTap: () => _openMonitorFlow(
                      context,
                      (c) => c.simulateError(SetupErrorType.monitorNotFound),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FlowTile(
                    title: 'Provisioning failed',
                    subtitle: 'Connected but WiFi/AWS setup broke',
                    onTap: () => _openMonitorFlow(
                      context,
                      (c) => c.simulateError(SetupErrorType.monitorProvisioningFailed),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FlowTile(
                    title: 'Already taken',
                    subtitle: 'Monitor belongs to another account',
                    onTap: () => _openMonitorFlow(context, (c) => c.simulateAlreadyTaken()),
                  ),

                  const SizedBox(height: 28),

                  // ── Motor – Basic ────────────────────────────────────────
                  _SectionLabel('Motor Setup — Basic'),
                  const SizedBox(height: 12),
                  _FlowTile(
                    title: 'Full pairing flow',
                    subtitle: 'Power up → Turn on → BT → Scan → Paired',
                    onTap: () => _openMotorFlow(context, MotorType.basic),
                  ),
                  const SizedBox(height: 8),
                  _FlowTile(
                    title: 'Multiple found',
                    subtitle: 'Horizontal picker — 2 motors nearby',
                    onTap: () => _openMotorFlow(
                      context,
                      MotorType.basic,
                      init: (c) => Future.microtask(c.simulateMultipleFound),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FlowTile(
                    title: 'Scan error',
                    subtitle: 'Could not start scanning',
                    onTap: () => _openMotorFlow(
                      context,
                      MotorType.basic,
                      init: (c) => Future.microtask(c.simulateError),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FlowTile(
                    title: 'Scan timeout',
                    subtitle: 'Timed out — nothing found',
                    onTap: () => _openMotorFlow(
                      context,
                      MotorType.basic,
                      init: (c) => Future.microtask(c.simulateTimeout),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Motor – Premium ──────────────────────────────────────
                  _SectionLabel('Motor Setup — Premium'),
                  const SizedBox(height: 12),
                  _FlowTile(
                    title: 'Full pairing flow',
                    subtitle: 'Power up (composite) → Turn on knobs → BT spotlight → Scan',
                    onTap: () => _openMotorFlow(context, MotorType.premium),
                  ),
                  const SizedBox(height: 8),
                  _FlowTile(
                    title: 'Bluetooth denied',
                    subtitle: 'Permission not granted',
                    onTap: () => _openMotorFlow(
                      context,
                      MotorType.premium,
                      init: (c) => Future.microtask(c.simulateBluetoothDenied),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FlowTile(
                    title: 'Invalid bond',
                    subtitle: 'Existing BT bond — re-pair flow',
                    onTap: () => _openMotorFlow(
                      context,
                      MotorType.premium,
                      init: (c) => Future.microtask(c.simulateInvalidBond),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Monitor sheet ──────────────────────────────────────────────────────────────

class _SetupFlowSheet extends StatelessWidget {
  final bool isChangeWiFi;
  const _SetupFlowSheet({this.isChangeWiFi = false});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.color.surfacePrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.color.borderNormal,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Expanded(
              child: MonitorProvisioningPage(
                isLaunchedToChangeWiFi: isChangeWiFi,
                onMonitorAdded: () => Navigator.of(context).pop(),
                onNavigatedBack: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Motor sheet ────────────────────────────────────────────────────────────────

class _MotorFlowSheet extends StatelessWidget {
  final MotorType motorType;
  const _MotorFlowSheet({required this.motorType});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.color.surfacePrimary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.color.borderNormal,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Expanded(child: PairDeviceModal(motorType: motorType)),
          ],
        ),
      ),
    );
  }
}

// ── Shared UI ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: context.color.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _FlowTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FlowTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.color.surfacePrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.color.borderSubdued),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.color.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.color.textTertiary),
          ],
        ),
      ),
    );
  }
}
