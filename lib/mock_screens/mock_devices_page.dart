import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/button.dart';
import '../common/label_button.dart';
import '../common/label_row.dart';
import '../common/modal_sheet.dart';
import '../common/mock_bottom_nav.dart';
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
    bool showHeader = false;
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
                child: NoiseDetectionBody(
                  level: _selectedMode,
                  onlyBabyCries: _onlyBabyCries,
                  title: showHeader ? 'Mode selection' : null,
                  subtitle: showHeader
                      ? 'Choose how sensitive the monitor should be to sounds.'
                      : null,
                  onLevelSelected: (level) {
                    setState(() => _selectedMode = level);
                    Navigator.of(ctx).pop();
                  },
                  onOnlyBabyCriesChanged: (v) => setState(() => _onlyBabyCries = v),
                  onContinue: () => Navigator.of(ctx).pop(),
                  continueLabel: 'Done',
                ),
              ),
            ),
          ],
        ),
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
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _MotorCard(
                        state: _motorState,
                        onAction: _motorState == _MotorState.ready
                            ? _showProgramSheet
                            : () => setState(() => _motorState = _MotorState.ready),
                        onMore: _showMotorContextMenu,
                      ),
                      const SizedBox(height: 12),
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
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 16),
      child: Row(
        children: [
          _CircleIconBtn(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: context.color.textPrimary),
          ),
          const SizedBox(width: 8),
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
                  color: context.color.surfacePrimary,
                  surfaceTintColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  elevation: 4,
                  shadowColor: context.color.overlayLevel1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: widget.child,
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
    final c = context.color;
    final cardColor = c.surfacePrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // Matches Figma: 0px 2px 32px rgba(0,0,0,0.06)
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 32,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
          color: cardColor,
          child: SizedBox(
            height: 285,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full-bleed image
                Image.asset(
                  'assets/images/motor_nobg.png',
                  fit: BoxFit.cover,
                ),
                // Gradient: transparent → surfacePrimary (73.1% stop)
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  height: 162,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, cardColor, cardColor],
                        stops: const [0.0, 0.731, 1.0],
                      ),
                    ),
                  ),
                ),
                // Stat chips when running (above info row)
                if (isRunning)
                  const Positioned(
                    left: 20, right: 20, bottom: 80,
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
                // Info row overlaid at bottom (top: 217px = bottom: ~20px)
                Positioned(
                  left: 20, right: 20, bottom: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRunning ? 'Running' : 'Ready',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: c.brandPrimary,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Motorino',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: c.brandSecondary,
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
                // Dots button — top: 14, right: 16
                Positioned(
                  top: 14, right: 16,
                  child: _DotsBtn(onTap: onMore),
                ),
              ],
            ),
          ),
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
    final c = context.color;
    final cardColor = c.surfacePrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 32,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
          color: cardColor,
          child: SizedBox(
            height: 285,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full-bleed image
                Image.asset(
                  'assets/images/monitor_nobg.png',
                  fit: BoxFit.cover,
                ),
                // Gradient: transparent → surfacePrimary (73.1% stop)
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  height: 162,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, cardColor, cardColor],
                        stops: const [0.0, 0.731, 1.0],
                      ),
                    ),
                  ),
                ),
                // Info row overlaid at bottom
                Positioned(
                  left: 20, right: 20, bottom: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connected',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: c.brandPrimary,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Baboonies',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: c.brandSecondary,
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
                // Dots button — top: 14, right: 16
                Positioned(
                  top: 14, right: 16,
                  child: _DotsBtn(onTap: onMore),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
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
    final borderRadius = BorderRadius.circular(16);
    return Material(
      color: selected ? c.surfacePrimary : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: c.borderNormal, width: selected ? 2 : 1),
      ),
      elevation: selected ? 2 : 0,
      shadowColor: c.overlayLevel1,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
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
        padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
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
                width: 18, height: 18,
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
      child: SizedBox(
        width: 32, height: 32,
        child: Center(
          child: Icon(Icons.more_horiz, size: 22, color: context.color.textPrimary),
        ),
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

