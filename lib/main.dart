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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Setup Flows',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
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

  void _openMonitorFlow(BuildContext context) {
    final br = DeviceRadius.instance.bottomSheetRadius;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (ctx) => AnimatedPadding(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          left: 6,
          right: 6,
          top: 6,
          bottom: MediaQuery.of(ctx).viewInsets.bottom > 0 ? 0 : 6,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(32),
            topRight: const Radius.circular(32),
            bottomLeft: Radius.circular(br),
            bottomRight: Radius.circular(br),
          ),
          child: ColoredBox(
            color: getModalSheetBackgroundColor(ctx, ModalSheetBackground.white),
            child: BlocProvider(
              create: (_) => MockMonitorCubit(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height - 60,
                ),
                child: const MonitorProvisioningPage(),
              ),
            ),
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
