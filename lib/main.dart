import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'common/device_radius.dart';
import 'common/modal_sheet.dart';
import 'mock/mock_monitor_cubit.dart';
import 'mock/mock_motor_cubit.dart';
import 'pairing/motor_type.dart';
import 'pairing/pair_device_modal.dart';
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
      title: 'Moonboon Setup Flows',
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                        style: context.textStyle.headlineMedium.withColor(context.color.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Setup Flows',
                        style: context.textStyle.bodyMedium.withColor(context.color.textSecondary),
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

              const Spacer(),

              // Flow tiles
              _FlowTile(
                label: 'Motor Basic',
                subtitle: 'Power up → Name → Activate → Done',
                onTap: () => _openMotorFlow(context, MotorType.basic),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Motor Premium',
                subtitle: 'Power up → Knobs → Bluetooth → Activate → Done',
                onTap: () => _openMotorFlow(context, MotorType.premium),
              ),
              const SizedBox(height: 12),
              _FlowTile(
                label: 'Monitor',
                subtitle: 'Charge → Power up → WiFi → Provisioning → Done',
                onTap: () => _openMonitorFlow(context),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _openMotorFlow(BuildContext context, MotorType motorType) {
    _openSetupSheet(
      context,
      child: (ctx) => BlocProvider(
        create: (_) => MockMotorCubit(),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height - 60),
          child: PairDeviceModal(motorType: motorType),
        ),
      ),
    );
  }

  void _openMonitorFlow(BuildContext context) {
    _openSetupSheet(
      context,
      child: (ctx) => BlocProvider(
        create: (_) => MockMonitorCubit()..checkCurrentUser(),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                    style: context.textStyle.titleLarge.withColor(context.color.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.textStyle.bodySmall.withColor(context.color.textTertiary),
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
