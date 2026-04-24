import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/adaptive_indicators/noise_detection_indicator.dart';
import '../common/button.dart';
import '../common/label_button.dart';
import '../common/label_row.dart';
import '../common/label_row_navigable.dart';
import '../common/modal_sheet.dart';
import '../common/moonboon_scaffold.dart';
import '../common/section_divider.dart';
import '../common/surface_card.dart';
import '../common/toggle_switch.dart';
import '../setup_flow/component/noise_detection_body.dart';
import '../theme/theme_colors.dart';

/// 1:1 mock of monitor_details_page.dart
/// Sections (owner view, firmware available):
///   NoiseDetectionCard → MonitorSettingsSection → InviteUsersCard
///   → FirmwareUpdateCard → NetworkSection → SupportSection
///   → DataConsentCard → RemoveMonitorCard
class MockMonitorSettingsPage extends StatefulWidget {
  const MockMonitorSettingsPage({super.key});

  @override
  State<MockMonitorSettingsPage> createState() => _MockMonitorSettingsPageState();
}

class _MockMonitorSettingsPageState extends State<MockMonitorSettingsPage> {
  // Noise detection state
  NoiseDetectionLevel _noiseDetection = NoiseDetectionLevel.high;
  bool _onlyBabyCries = false;

  // MonitorSettingsSection state
  bool _muted = false;
  bool _lowPower = false;
  bool _streamingLed = true;

  // DataConsentCard state
  bool _dataConsent = true;
  bool _advancedExpanded = false;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final c = context.color;
    return MoonboonScaffold(
      appBar: MoonboonAppBar(
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                "Uljana's monitor",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'KeplerStd',
                  fontSize: 24,
                  color: c.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            SvgPicture.asset(
              'assets/icons/utility/edit.svg',
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
            ),
          ],
        ),
        trailing: Material(
          color: c.surfaceTertiary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/utility/power-toggle.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: topInset + 12,
              left: 24,
              right: 24,
              bottom: bottomInset + 24,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 1. Noise detection ───────────────────────────────────
                    _NoiseDetectionCard(
                      level: _noiseDetection,
                      onTap: () {
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
                                      level: _noiseDetection,
                                      onlyBabyCries: _onlyBabyCries,
                                      title: showHeader ? 'Mode selection' : null,
                                      subtitle: showHeader
                                          ? 'Choose how sensitive the monitor should be to sounds.'
                                          : null,
                                      onLevelSelected: (level) =>
                                          setState(() => _noiseDetection = level),
                                      onOnlyBabyCriesChanged: (v) =>
                                          setState(() => _onlyBabyCries = v),
                                      onContinue: () => Navigator.of(ctx).pop(),
                                      continueLabel: 'Done',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // ── 2. Monitor settings ──────────────────────────────────
                    SurfaceCard(
                      child: Column(
                        children: [
                          LabelRow(
                            iconPath: 'assets/icons/utility/bell-off.svg',
                            label: 'Mute notifications',
                            trailing: ToggleSwitch(
                              value: _muted,
                              onChanged: (v) => setState(() => _muted = v),
                            ),
                          ),
                          const SectionDivider(),
                          LabelRow(
                            iconPath: 'assets/icons/utility/moon-outline.svg',
                            label: 'Streaming indicator',
                            trailing: ToggleSwitch(
                              value: _streamingLed,
                              onChanged: (v) => setState(() => _streamingLed = v),
                            ),
                          ),
                          const SectionDivider(),
                          LabelRow(
                            iconPath: 'assets/icons/battery/battery_low_power_mode.svg',
                            label: 'Low-power mode',
                            trailing: ToggleSwitch(
                              value: _lowPower,
                              onChanged: (v) => setState(() => _lowPower = v),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── 3. Invite users ──────────────────────────────────────
                    SurfaceCard(
                      child: LabelRow(
                        iconPath: 'assets/icons/utility/users.svg',
                        label: 'Share monitor',
                        trailing: LabelButton(
                          label: 'Invite',
                          onTap: () {},
                        ),
                      ),
                    ),

                    // ── 4. Firmware update ───────────────────────────────────
                    SurfaceCard(
                      child: LabelRow(
                        iconPath: 'assets/icons/utility/refresh.svg',
                        label: 'Firmware update available',
                        trailing: LabelButton(
                          label: 'Update',
                          onTap: () {},
                        ),
                      ),
                    ),

                    // ── 5. Network ───────────────────────────────────────────
                    _NetworkCard(),

                    // ── 6. Support ───────────────────────────────────────────
                    SurfaceCard(
                      child: Column(
                        children: [
                          LabelRowNavigable(
                            iconPath: 'assets/icons/utility/message-smile-circle.svg',
                            label: 'Help improve alerts',
                            labelColor: c.textTertiary,
                            onTap: () {},
                          ),
                          const SectionDivider(),
                          LabelRowNavigable(
                            iconPath: 'assets/icons/utility/faq.svg',
                            label: 'FAQ',
                            labelColor: c.textTertiary,
                            onTap: () {},
                          ),
                          const SectionDivider(),
                          LabelRowNavigable(
                            iconPath: 'assets/icons/utility/book-closed.svg',
                            label: 'User manual',
                            labelColor: c.textTertiary,
                            onTap: () {},
                          ),
                          const SectionDivider(),
                          LabelRowNavigable(
                            iconPath: 'assets/icons/utility/mail.svg',
                            label: 'Contact support',
                            labelColor: c.textTertiary,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    // ── 7. Data consent ──────────────────────────────────────
                    SurfaceCard(
                      child: Column(
                        children: [
                          LabelRow(
                            iconPath: 'assets/icons/utility/cloud-outline.svg',
                            label: 'Data collection consent',
                            trailing: ToggleSwitch(
                              value: _dataConsent,
                              onChanged: (v) => setState(() => _dataConsent = v),
                            ),
                          ),
                          const SectionDivider(),
                          LabelRowNavigable(
                            iconPath: 'assets/icons/utility/info-hexagon.svg',
                            label: 'Privacy policy',
                            labelColor: c.textTertiary,
                            onTap: () {},
                          ),
                          const SectionDivider(),
                          LabelRowNavigable(
                            iconPath: 'assets/icons/utility/info-hexagon.svg',
                            label: 'Technical information',
                            labelColor: c.textTertiary,
                            onTap: () {},
                          ),
                          const SectionDivider(),
                          _AdvancedSection(
                            isExpanded: _advancedExpanded,
                            onToggle: () => setState(() => _advancedExpanded = !_advancedExpanded),
                          ),
                        ],
                      ),
                    ),

                    // ── 8. Remove monitor ────────────────────────────────────
                    SurfaceCard(
                      child: LabelRow(
                        iconPath: 'assets/icons/utility/x-square.svg',
                        label: 'Remove the monitor',
                        trailing: LabelButton(
                          label: 'Remove',
                          variant: LabelButtonVariant.dangerous,
                          onTap: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Noise detection card ──────────────────────────────────────────────────────

class _NoiseDetectionCard extends StatelessWidget {
  final NoiseDetectionLevel level;
  final VoidCallback onTap;
  const _NoiseDetectionCard({required this.level, required this.onTap});

  static String _title(NoiseDetectionLevel level) => switch (level) {
        NoiseDetectionLevel.low => 'Quiet mode',
        NoiseDetectionLevel.medium => 'Standard mode',
        NoiseDetectionLevel.high => 'Maximum sensitivity',
      };

  static String _description(NoiseDetectionLevel level) => switch (level) {
        NoiseDetectionLevel.low => 'Only detects loud sounds.',
        NoiseDetectionLevel.medium => 'Detects most sounds at a normal level.',
        NoiseDetectionLevel.high => 'Detects all sounds, even very quiet ones.',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              spacing: 12,
              children: [
                NoiseDetectionIndicator(level: level, size: 48),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        children: [
                          Text(
                            _title(level),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _description(level),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/utility/chevron-selector-vertical.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(c.surfaceTertiary, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Network card ──────────────────────────────────────────────────────────────

class _NetworkCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final valueStyle = Theme.of(context).textTheme.labelMedium?.copyWith(color: c.textSecondary);
    final labelPill = BoxDecoration(
      color: c.surfacePrimary.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
    );
    return SurfaceCard(
      child: Column(
        children: [
          LabelRow(
            label: 'Network',
            labelColor: c.textTertiary,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: labelPill,
              child: Text('Moonboon', style: valueStyle),
            ),
          ),
          const SectionDivider(),
          LabelRow(
            label: 'Connection',
            labelColor: c.textTertiary,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: labelPill,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: c.feedbackSuccess, shape: BoxShape.circle),
                  ),
                  Text('Connected', style: valueStyle),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Button(
              onPressed: () {},
              buttonLabel: Text(
                'Change wifi',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.textPrimary),
              ),
              variant: ButtonVariant.primary,
              size: ButtonSize.standard,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Advanced expandable section ───────────────────────────────────────────────

class _AdvancedSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  const _AdvancedSection({required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final valueStyle = Theme.of(context).textTheme.labelMedium?.copyWith(color: c.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: LabelRow(
            iconPath: 'assets/icons/utility/advanced.svg',
            label: 'Advanced',
            labelColor: context.color.textTertiary,
            trailing: SvgPicture.asset(
              isExpanded
                  ? 'assets/icons/utility/chevron_up.svg'
                  : 'assets/icons/utility/chevron_right.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(c.surfaceTertiary, BlendMode.srcIn),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    LabelRow(label: 'Firmware version', trailing: Text('v2.4.1', style: valueStyle)),
                    const SectionDivider(),
                    LabelRow(label: 'MAC address', trailing: Text('A1:B2:C3:D4:E5:F6', style: valueStyle)),
                    const SectionDivider(),
                    LabelRow(label: 'Serial number', trailing: Text('MB-2024-001234', style: valueStyle)),
                    const SectionDivider(),
                    LabelRow(label: 'IP address', trailing: Text('192.168.1.42', style: valueStyle)),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
