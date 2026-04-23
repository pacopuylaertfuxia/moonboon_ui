import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/modal_sheet.dart';
import '../common/moonboon_scaffold.dart';
import '../common/noise_detection_picker_button.dart';
import '../common/telemetry_panel.dart';
import '../setup_flow/component/noise_detection_body.dart';
import '../theme/theme_colors.dart';
import 'mock_monitor_settings_page.dart';

abstract final class _VideoChannel {
  static const name     = 'com.moonboon/video_player';
  static const viewType = 'com.moonboon/native_video_player';
  static const startPip          = 'startPip';
  static const stopPip           = 'stopPip';
  static const playStateChanged  = 'playStateChanged';
  static const pipStateChanged   = 'pipStateChanged';
}

/// Mock of the live monitor stream page — token mapping from Figma node 416:2182.
class MockMonitorStreamPage extends StatefulWidget {
  const MockMonitorStreamPage({super.key});

  @override
  State<MockMonitorStreamPage> createState() => _MockMonitorStreamPageState();
}

class _MockMonitorStreamPageState extends State<MockMonitorStreamPage> {
  NoiseDetectionLevel _noiseDetection = NoiseDetectionLevel.high;
  bool _onlyBabyCries = false;

  void _openNoiseSheet() {
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
                child: ModeSelectionBody(
                  level: _noiseDetection,
                  onlyBabyCries: _onlyBabyCries,
                  title: showHeader ? 'Mode selection' : null,
                  subtitle: showHeader
                      ? 'Choose how sensitive the monitor should be to sounds.'
                      : null,
                  onLevelSelected: (level) => setState(() => _noiseDetection = level),
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
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final barHeight = topPadding + kToolbarHeight;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return MoonboonScaffold(
      appBar: MoonboonAppBar(
        padding: EdgeInsets.zero,
        titleWidget: NoiseDetectionPickerButton(
          level: _noiseDetection,
          isUpdating: false,
          onTap: _openNoiseSheet,
        ),
        trailing: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/settings.svg',
            colorFilter: ColorFilter.mode(context.color.textPrimary, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MockMonitorSettingsPage()),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: barHeight),
        child: _StreamBody(bottomPadding: bottomPadding),
      ),
    );
  }
}

class _StreamBody extends StatefulWidget {
  final double bottomPadding;
  const _StreamBody({required this.bottomPadding});

  @override
  State<_StreamBody> createState() => _StreamBodyState();
}

class _StreamBodyState extends State<_StreamBody> {
  bool _showFirmwareCard = true;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Telemetry row — surfacePrimary bg + surfaceQuaternary border
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 6.0, bottom: 12.0, left: 16.0, right: 16.0),
            child: TelemetryPanel(
              batteryLevel: 0.62,
              isCharging: false,
              signalStrength: 0.90,
              temperature: 23,
            ),
          ),
        ),
        // Video preview — full-width with right-edge button pill
        const SliverToBoxAdapter(
          child: _VideoPreview(),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Firmware update card
        if (_showFirmwareCard) SliverToBoxAdapter(
          child: _FirmwareUpdateCard(onDismiss: () => setState(() => _showFirmwareCard = false)),
        ),
        if (_showFirmwareCard) const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Notifications section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
            child: Text(
              'Notifications',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.color.textPrimary),
            ),
          ),
        ),
        // Notification cards — surfaceQuaternary border, textSecondary titles
        SliverList.separated(
          itemCount: _mockNotifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _NotificationCard(n: _mockNotifications[i]),
        ),
        SliverToBoxAdapter(child: SizedBox(height: widget.bottomPadding + 24)),
      ],
    );
  }
}

// ── Video preview ────────────────────────────────────────────────────────────

class _VideoPreview extends StatefulWidget {
  const _VideoPreview();

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview>
    with SingleTickerProviderStateMixin {
  static const _channel = MethodChannel(_VideoChannel.name);

  bool _isPlaying = true;
  bool _isPip = false;
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconOpacity;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _iconOpacity = CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOut);

    _channel.setMethodCallHandler((call) async {
      if (call.method == _VideoChannel.playStateChanged) {
        setState(() => _isPlaying = call.arguments as bool);
        await _iconCtrl.forward(from: 0);
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) await _iconCtrl.reverse();
      } else if (call.method == _VideoChannel.pipStateChanged) {
        if (mounted) setState(() => _isPip = call.arguments as bool);
      }
    });
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    _iconCtrl.dispose();
    super.dispose();
  }

  Future<void> _togglePip() async {
    try {
      if (_isPip) {
        await _channel.invokeMethod(_VideoChannel.stopPip);
      } else {
        await _channel.invokeMethod(_VideoChannel.startPip);
      }
    } catch (e) {
      debugPrint('[PiP] error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera feed — native video player (sample.mov from Runner bundle)
          if (Platform.isIOS)
            const UiKitView(
              viewType: _VideoChannel.viewType,
              creationParamsCodec: StandardMessageCodec(),
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Icon(Icons.videocam_off_rounded, color: context.color.textTertiary, size: 40),
              ),
            ),
          // Play/pause icon flash on tap
          Center(
            child: FadeTransition(
              opacity: _iconOpacity,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          // Right-edge button pill — surfacePrimary + surfaceQuaternary border (Figma mapping)
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _VideoButtonPill(isPip: _isPip, onPipTap: _togglePip),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoButtonPill extends StatelessWidget {
  final bool isPip;
  final VoidCallback onPipTap;
  const _VideoButtonPill({required this.isPip, required this.onPipTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: c.surfacePrimary,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: c.surfaceQuaternary),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PillButton(
                assetPath: isPip
                    ? 'assets/icons/fullscreen/minimize.svg'
                    : 'assets/icons/fullscreen/maximize.svg',
                isFirst: true,
                onTap: onPipTap,
              ),
              const _PillButton(assetPath: 'assets/icons/volume/volume_on.svg'),
              const _PillButton(assetPath: 'assets/icons/controls/camera.svg', isLast: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String assetPath;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;
  const _PillButton({
    required this.assetPath,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Padding(
      padding: EdgeInsets.only(
        left: 10, right: 10,
        top: isFirst ? 16 : 8,
        bottom: isLast ? 16 : 8,
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(context.color.textPrimary, BlendMode.srcIn),
      ),
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: icon);
    }
    return icon;
  }
}

// ── Firmware update card ─────────────────────────────────────────────────────

class _FirmwareUpdateCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const _FirmwareUpdateCard({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
        decoration: BoxDecoration(
          color: c.surfacePrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.surfaceQuaternary),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Update required',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'From time to time, we release firmware upgrades to enhance your experience. Please be patient, as this process takes a few minutes and will require you to reconnect to the Monitor afterwards.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 16),
                // CTA button — surfaceTertiary bg (the high-contrast token)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: c.surfaceTertiary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Update firmware',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.textPrimary),
                  ),
                ),
              ],
            ),
            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.surfaceQuaternary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: c.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification cards ───────────────────────────────────────────────────────

class _MockNotification {
  final String type; // 'sound' | 'cry' | 'alert' | 'play'
  final String title;
  final String body;
  final String timeAgo;
  final bool isIntelligent;
  const _MockNotification({
    required this.type,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isIntelligent = false,
  });
}

const _mockNotifications = [
  _MockNotification(
    type: 'sound',
    title: 'Sound detected',
    body: 'Your baby might need your attention',
    timeAgo: 'Just now',
    isIntelligent: true,
  ),
  _MockNotification(
    type: 'cry',
    title: 'Cry detected',
    body: 'We recommend checking up on your baby to see if everything is ok',
    timeAgo: '3m ago',
    isIntelligent: true,
  ),
  _MockNotification(
    type: 'alert',
    title: 'Uncertain sound detected',
    body: 'We picked up some sound',
    timeAgo: '17m ago',
    isIntelligent: true,
  ),
  _MockNotification(
    type: 'play',
    title: 'Streaming started',
    body: 'You are successfully streaming',
    timeAgo: '32m ago',
  ),
];

TextStyle? _getLabelStyle(BuildContext context) =>
    Theme.of(context).textTheme.labelSmall?.copyWith(
      color: context.color.textTertiary,
    );

class _NotificationCard extends StatelessWidget {
  final _MockNotification n;
  const _NotificationCard({required this.n});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 4),
        decoration: BoxDecoration(
          color: c.surfacePrimary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.surfaceQuaternary), // surfaceQuaternary per Figma
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _NotificationIcon(type: n.type),
                Expanded(
                  child: Text(
                    n.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: c.textSecondary, // textSecondary per Figma (warm sand, not white)
                    ),
                  ),
                ),
                Text(n.timeAgo, style: _getLabelStyle(context)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              n.body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary),
            ),
            if (n.isIntelligent) const _FeedbackRow() else const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final String type;
  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      'sound' => 'assets/icons/volume/volume_on.svg',
      'cry'   => 'assets/icons/feedback/face_frown.svg',
      'alert' => 'assets/icons/notification/alert_circle.svg',
      'play'  => 'assets/icons/controls/play.svg',
      _       => null,
    };
    if (icon == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: SvgPicture.asset(
        icon,
        width: 18,
        height: 18,
        colorFilter: ColorFilter.mode(context.color.brandSecondary, BlendMode.srcIn),
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  const _FeedbackRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Was this accurate?', style: _getLabelStyle(context)),
        const SizedBox(width: 8),
        const _ThumbButton(assetPath: 'assets/icons/feedback/positive.svg'),
        const _ThumbButton(assetPath: 'assets/icons/feedback/negative.svg'),
      ],
    );
  }
}

class _ThumbButton extends StatelessWidget {
  final String assetPath;
  const _ThumbButton({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          assetPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(context.color.borderStrong, BlendMode.srcIn),
        ),
      ),
    );
  }
}

