import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/button.dart';
import '../common/label_button.dart';
import '../common/label_row.dart';
import '../common/modal_sheet.dart';
import '../common/mock_bottom_nav.dart';
import '../setup_flow/component/noise_detection_body.dart';
import '../common/section_divider.dart';
import '../common/toggle_switch.dart';
import '../setup_flow/component/noise_detection_body.dart';
import '../theme/theme_colors.dart';

// ── Devices tab — Design Vision ────────────────────────────────────────────────

enum _MotorState { ready, running }
enum _MotorProgram { quick, medium, long }

// Maps 1:1 to NoiseDetectionLevel — kept for readable naming in this file
extension _NoiseLevel on NoiseDetectionLevel {
  String get modeLabel => switch (this) {
        NoiseDetectionLevel.low => 'Quiet mode',
        NoiseDetectionLevel.medium => 'Standard mode',
        NoiseDetectionLevel.high => 'Maximum mode',
      };
}

class MockDevicesPage extends StatefulWidget {
  const MockDevicesPage({super.key});

  @override
  State<MockDevicesPage> createState() => _MockDevicesPageState();
}

class _MockDevicesPageState extends State<MockDevicesPage> {
  _MotorState _motorState = _MotorState.ready;
  _MotorProgram _selectedProgram = _MotorProgram.medium;
  NoiseDetectionLevel _selectedMode = NoiseDetectionLevel.high;
  bool _onlyBabyCries = false;
  bool _muteNotifications = true;
  bool _lowPowerMode = false;
  bool _streamingMoonlight = false;

  OverlayEntry? _contextMenuEntry;

  void _dismissContextMenu() {
    _contextMenuEntry?.remove();
    _contextMenuEntry = null;
  }

  // ── Floating context menus ────────────────────────────────────────────────

  void _showMotorContextMenu(BuildContext btnCtx) {
    _dismissContextMenu();
    final box = btnCtx.findRenderObject()! as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    // Bottom of menu aligns to bottom of dots button → menu grows upward
    final menuBottom = screenH - (offset.dy + box.size.height);

    _contextMenuEntry = OverlayEntry(
      builder: (_) => _ContextMenuOverlay(
        onDismiss: _dismissContextMenu,
        right: 16,
        bottom: menuBottom,
        child: LabelRow(
          iconPath: 'assets/icons/utility/x-square.svg',
          label: 'Remove the motor',
          trailing: LabelButton(
            label: 'Remove',
            variant: LabelButtonVariant.dangerous,
            onTap: _dismissContextMenu,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_contextMenuEntry!);
  }

  void _showMonitorContextMenu(BuildContext btnCtx) {
    _dismissContextMenu();
    final box = btnCtx.findRenderObject()! as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    final menuBottom = screenH - (offset.dy + box.size.height);

    _contextMenuEntry = OverlayEntry(
      builder: (_) => _ContextMenuOverlay(
        onDismiss: _dismissContextMenu,
        right: 16,
        bottom: menuBottom,
        child: _MonitorContextMenu(
          muteNotifications: _muteNotifications,
          lowPowerMode: _lowPowerMode,
          streamingMoonlight: _streamingMoonlight,
          onMuteChanged: (v) => setState(() => _muteNotifications = v),
          onLowPowerChanged: (v) => setState(() => _lowPowerMode = v),
          onStreamingChanged: (v) => setState(() => _streamingMoonlight = v),
          onRemove: _dismissContextMenu,
        ),
      ),
    );
    Overlay.of(context).insert(_contextMenuEntry!);
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────────

  void _showProgramSheet() {
    ModalSheet.show(
      context: context,
      hasPadding: false,
      duration: Duration.zero,
      background: ModalSheetBackground.cream,
      child: _ProgramSheet(
        selected: _selectedProgram,
        onSelect: (p) => setState(() => _selectedProgram = p),
        onStart: () {
          setState(() => _motorState = _MotorState.running);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showModeSheet() {
    ModalSheet.show(
      context: context,
      hasPadding: false,
      duration: Duration.zero,
      background: ModalSheetBackground.cream,
      child: NoiseDetectionBody(
        level: _selectedMode,
        onlyBabyCries: _onlyBabyCries,
        onLevelSelected: (level) => setState(() => _selectedMode = level),
        onOnlyBabyCriesChanged: (v) => setState(() => _onlyBabyCries = v),
        onContinue: () => Navigator.of(context).pop(),
        continueLabel: 'Done',
      ),
    );
  }

  @override
  void dispose() {
    _dismissContextMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.surfaceSecondary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _MotorCard(
                        state: _motorState,
                        onAction: _motorState == _MotorState.ready
                            ? _showProgramSheet
                            : () => setState(() => _motorState = _MotorState.ready),
                        onMore: _showMotorContextMenu,
                      ),
                      const SizedBox(height: 16),
                      _MonitorCard(
                        modeLabel: _selectedMode.modeLabel,
                        onModeChevron: _showModeSheet,
                        onMore: _showMonitorContextMenu,
                      ),
                      SizedBox(height: mockNavBarTotalHeight(context) + 16),
                    ]),
                  ),
                ),
              ],
            ),
            const MockBottomNav(activeIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      child: Row(
        children: [
          Text(
            'Devices',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: context.color.textPrimary,
            ),
          ),
          const Spacer(),
          _CircleIconBtn(
            onTap: () {},
            child: Icon(Icons.add, size: 20, color: context.color.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Floating context menu overlay ──────────────────────────────────────────────

class _ContextMenuOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final double right;
  final double bottom;
  final Widget child;

  const _ContextMenuOverlay({
    required this.onDismiss,
    required this.right,
    required this.bottom,
    required this.child,
  });

  @override
  State<_ContextMenuOverlay> createState() => _ContextMenuOverlayState();
}

class _ContextMenuOverlayState extends State<_ContextMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tap-outside barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        // Menu card — bottom-anchored, grows upward, right-aligned
        Positioned(
          right: widget.right,
          bottom: widget.bottom,
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              alignment: Alignment.bottomRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 32,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.color.surfacePrimary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: context.color.overlayLevel1,
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: context.color.overlayLevel1.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Monitor context menu content ───────────────────────────────────────────────

class _MonitorContextMenu extends StatefulWidget {
  final bool muteNotifications;
  final bool lowPowerMode;
  final bool streamingMoonlight;
  final ValueChanged<bool> onMuteChanged;
  final ValueChanged<bool> onLowPowerChanged;
  final ValueChanged<bool> onStreamingChanged;
  final VoidCallback onRemove;

  const _MonitorContextMenu({
    required this.muteNotifications,
    required this.lowPowerMode,
    required this.streamingMoonlight,
    required this.onMuteChanged,
    required this.onLowPowerChanged,
    required this.onStreamingChanged,
    required this.onRemove,
  });

  @override
  State<_MonitorContextMenu> createState() => _MonitorContextMenuState();
}

class _MonitorContextMenuState extends State<_MonitorContextMenu> {
  late bool _mute;
  late bool _lowPower;
  late bool _streaming;

  @override
  void initState() {
    super.initState();
    _mute = widget.muteNotifications;
    _lowPower = widget.lowPowerMode;
    _streaming = widget.streamingMoonlight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelRow(
          iconPath: 'assets/icons/utility/bell-off.svg',
          label: 'Mute notifications',
          trailing: ToggleSwitch(
            value: _mute,
            onChanged: (v) {
              setState(() => _mute = v);
              widget.onMuteChanged(v);
            },
          ),
        ),
        const SectionDivider(),
        LabelRow(
          iconPath: 'assets/icons/battery/battery_low_power_mode.svg',
          label: 'Low-power mode',
          trailing: ToggleSwitch(
            value: _lowPower,
            onChanged: (v) {
              setState(() => _lowPower = v);
              widget.onLowPowerChanged(v);
            },
          ),
        ),
        const SectionDivider(),
        LabelRow(
          iconPath: 'assets/icons/utility/moon-outline.svg',
          label: 'Streaming moonlight',
          trailing: ToggleSwitch(
            value: _streaming,
            onChanged: (v) {
              setState(() => _streaming = v);
              widget.onStreamingChanged(v);
            },
          ),
        ),
        const SectionDivider(),
        LabelRow(
          iconPath: 'assets/icons/utility/x-square.svg',
          label: 'Remove the monitor',
          trailing: LabelButton(
            label: 'Remove',
            variant: LabelButtonVariant.dangerous,
            onTap: widget.onRemove,
          ),
        ),
      ],
    );
  }
}

// ── Motor card ─────────────────────────────────────────────────────────────────

class _MotorCard extends StatelessWidget {
  final _MotorState state;
  final VoidCallback onAction;
  final void Function(BuildContext) onMore;

  const _MotorCard({
    required this.state,
    required this.onAction,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning = state == _MotorState.running;
    final cardColor = context.color.surfacePrimary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ColoredBox(
        color: cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: isRunning ? 268 : 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/motor_lifestyle.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: 130,
                    child: _cardGradient(cardColor),
                  ),
                  Positioned(
                    top: 14, right: 14,
                    child: _DotsBtn(onTap: onMore),
                  ),
                  if (isRunning)
                    const Positioned(
                      left: 20, right: 20, bottom: 16,
                      child: Row(
                        children: [
                          _StatChip(label: 'Ends', value: '19:34'),
                          SizedBox(width: 8),
                          _StatChip(label: 'Ends in', value: '1:58'),
                          SizedBox(width: 8),
                          _StatChip(label: 'Tempo', value: 'Medium'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRunning ? 'Running' : 'Ready',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.color.brandSecondary,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Motorino',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.color.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ActionPill(
                    label: isRunning ? 'Stop program' : 'Start program',
                    onTap: onAction,
                    showChevron: !isRunning,
                    filled: isRunning,
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

// ── Monitor card ───────────────────────────────────────────────────────────────

class _MonitorCard extends StatelessWidget {
  final String modeLabel;
  final VoidCallback onModeChevron;
  final void Function(BuildContext) onMore;

  const _MonitorCard({
    required this.modeLabel,
    required this.onModeChevron,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = context.color.surfacePrimary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ColoredBox(
        color: cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/monitor_lifestyle.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: 130,
                    child: _cardGradient(cardColor),
                  ),
                  Positioned(
                    top: 14, right: 14,
                    child: _DotsBtn(onTap: onMore),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connected',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.color.feedbackSuccess,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Baboonies',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.color.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ActionPill(
                    label: modeLabel,
                    onTap: onModeChevron,
                    showChevron: true,
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

// ── Program sheet ──────────────────────────────────────────────────────────────

class _ProgramSheet extends StatefulWidget {
  final _MotorProgram selected;
  final ValueChanged<_MotorProgram> onSelect;
  final VoidCallback onStart;

  const _ProgramSheet({
    required this.selected,
    required this.onSelect,
    required this.onStart,
  });

  @override
  State<_ProgramSheet> createState() => _ProgramSheetState();
}

class _ProgramSheetState extends State<_ProgramSheet> {
  late _MotorProgram _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProgramItem(
            icon: Icons.access_time_rounded,
            title: 'Quick program',
            subtitle: 'This program lasts 30 minutes',
            selected: _selected == _MotorProgram.quick,
            onTap: () => setState(() {
              _selected = _MotorProgram.quick;
              widget.onSelect(_selected);
            }),
          ),
          const SizedBox(height: 8),
          _ProgramItem(
            icon: Icons.access_time_rounded,
            title: 'Medium program',
            subtitle: 'This program lasts 2:30 hours',
            selected: _selected == _MotorProgram.medium,
            onTap: () => setState(() {
              _selected = _MotorProgram.medium;
              widget.onSelect(_selected);
            }),
          ),
          const SizedBox(height: 8),
          _ProgramItem(
            icon: Icons.access_time_rounded,
            title: 'Long program',
            subtitle: 'This program lasts 5:00 hours',
            selected: _selected == _MotorProgram.long,
            onTap: () => setState(() {
              _selected = _MotorProgram.long;
              widget.onSelect(_selected);
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Button(
              buttonLabel: const Text('Start program'),
              variant: ButtonVariant.primary,
              size: ButtonSize.lg,
              onPressed: widget.onStart,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ProgramItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? c.surfacePrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: c.borderNormal,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: c.surfaceTertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: c.textSecondary),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.textTertiary,
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

// ── Card sub-widgets ───────────────────────────────────────────────────────────

class _ActionPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool showChevron;
  final bool filled;

  const _ActionPill({
    required this.label,
    required this.onTap,
    this.showChevron = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? context.color.textPrimary : context.color.surfaceTertiary;
    final fg = filled ? context.color.textInverse : context.color.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
            ),
            if (showChevron) ...[
              const SizedBox(width: 4),
              SvgPicture.asset(
                'assets/icons/utility/chevron-selector-vertical.svg',
                width: 16, height: 16,
                colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.color.surfacePrimary.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.color.textTertiary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.color.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsBtn extends StatelessWidget {
  final void Function(BuildContext) onTap;
  const _DotsBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: context.color.surfacePrimary.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_horiz, size: 18, color: context.color.textPrimary),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _CircleIconBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: context.color.surfacePrimary,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Gradient helper ────────────────────────────────────────────────────────────

Widget _cardGradient(Color cardColor) => DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        cardColor.withValues(alpha: 0),
        cardColor.withValues(alpha: 0.9),
        cardColor,
      ],
      stops: const [0.0, 0.6, 1.0],
    ),
  ),
);
