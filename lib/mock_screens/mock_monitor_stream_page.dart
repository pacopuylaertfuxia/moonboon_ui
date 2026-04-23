import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/button.dart';
import '../common/modal_sheet.dart';
import '../common/moonboon_scaffold.dart';
import '../common/noise_detection_picker_button.dart';
import '../common/surface_card.dart';
import '../common/telemetry_panel.dart';
import '../setup_flow/component/noise_detection_body.dart';
import '../theme/theme_colors.dart';
import 'mock_monitor_settings_page.dart';

// ── Channel constants ─────────────────────────────────────────────────────────

abstract final class _VideoChannel {
  static const name             = 'com.moonboon/video_player';
  static const viewType         = 'com.moonboon/native_video_player';
  static const startPip         = 'startPip';
  static const stopPip          = 'stopPip';
  static const playStateChanged = 'playStateChanged';
  static const pipStateChanged  = 'pipStateChanged';
}

// ── Spacing constants local to this screen ────────────────────────────────────

abstract final class _S {
  static const double pagePad    = 16;
  static const double pillRadius = 100;
}

// ── Root page ─────────────────────────────────────────────────────────────────

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
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
                context.color.textPrimary, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => const MockMonitorSettingsPage()),
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

// ── Scrollable body ───────────────────────────────────────────────────────────

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
        // Telemetry strip
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                _S.pagePad, 6, _S.pagePad, 12),
            child: TelemetryPanel(
              batteryLevel: 0.62,
              isCharging: false,
              signalStrength: 0.90,
              temperature: 23,
            ),
          ),
        ),
        // 16:9 video preview
        const SliverToBoxAdapter(child: _VideoPreview()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Firmware update card (dismissible)
        if (_showFirmwareCard) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _S.pagePad),
              child: _FirmwareUpdateCard(
                onDismiss: () =>
                    setState(() => _showFirmwareCard = false),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
        // Notifications header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
                left: _S.pagePad, right: _S.pagePad, bottom: 8),
            child: Text(
              'Notifications',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.color.textPrimary),
            ),
          ),
        ),
        // Notification cards
        SliverPadding(
          padding:
              const EdgeInsets.symmetric(horizontal: _S.pagePad),
          sliver: SliverList.separated(
            itemCount: _mockNotifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _NotificationCard(n: _mockNotifications[i]),
          ),
        ),
        SliverToBoxAdapter(
            child: SizedBox(height: widget.bottomPadding + 24)),
      ],
    );
  }
}

// ── Video preview ─────────────────────────────────────────────────────────────

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
    _iconOpacity =
        CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOut);

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
      await _channel.invokeMethod(
          _isPip ? _VideoChannel.stopPip : _VideoChannel.startPip);
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
          // Native video (iOS) / black placeholder (other platforms)
          if (Platform.isIOS)
            const UiKitView(
              viewType: _VideoChannel.viewType,
              creationParamsCodec: StandardMessageCodec(),
            )
          else
            ColoredBox(
              color: Colors.black,
              child: Center(
                child: Icon(Icons.videocam_off_rounded,
                    color: context.color.textTertiary, size: 40),
              ),
            ),
          // Play/pause flash overlay
          Center(
            child: FadeTransition(
              opacity: _iconOpacity,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0x73000000), // black @ 45%
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          // Right-edge control pill
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _VideoButtonPill(
                  isPip: _isPip, onPipTap: _togglePip),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Right-edge pill with 3 controls ──────────────────────────────────────────

class _VideoButtonPill extends StatelessWidget {
  final bool isPip;
  final VoidCallback onPipTap;
  const _VideoButtonPill(
      {required this.isPip, required this.onPipTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return ClipRRect(
      borderRadius: BorderRadius.circular(_S.pillRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: c.surfacePrimary.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(_S.pillRadius),
            border: Border.all(color: c.borderSubdued),
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
              _PillButton(
                  assetPath: 'assets/icons/volume/volume_on.svg'),
              _PillButton(
                assetPath: 'assets/icons/controls/camera.svg',
                isLast: true,
              ),
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
        left: 10,
        right: 10,
        top: isFirst ? 16 : 8,
        bottom: isLast ? 16 : 8,
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
            context.color.textPrimary, BlendMode.srcIn),
      ),
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: icon);
    }
    return icon;
  }
}

// ── Firmware update card ──────────────────────────────────────────────────────

class _FirmwareUpdateCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const _FirmwareUpdateCard({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update required',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.color.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'From time to time, we release firmware upgrades to enhance '
                'your experience. This process takes a few minutes and will '
                'require you to reconnect to the Monitor afterwards.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.color.textSecondary),
              ),
              const SizedBox(height: 16),
              Button(
                buttonLabel: const Text('Update firmware'),
                onPressed: () {},
                variant: ButtonVariant.primary,
                size: ButtonSize.medium,
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.color.surfaceTertiary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close,
                    size: 16, color: context.color.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification cards ────────────────────────────────────────────────────────

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
    body: 'We recommend checking up on your baby',
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

class _NotificationCard extends StatelessWidget {
  final _MockNotification n;
  const _NotificationCard({required this.n});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NotificationIcon(type: n.type),
              Expanded(
                child: Text(
                  n.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary),
                ),
              ),
              Text(
                n.timeAgo,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            n.body,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
          if (n.isIntelligent)
            const _FeedbackRow()
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final String type;
  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final path = switch (type) {
      'sound' => 'assets/icons/volume/volume_on.svg',
      'cry'   => 'assets/icons/feedback/face_frown.svg',
      'alert' => 'assets/icons/notification/alert_circle.svg',
      'play'  => 'assets/icons/controls/play.svg',
      _       => null,
    };
    if (path == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: SvgPicture.asset(
        path,
        width: 18,
        height: 18,
        colorFilter: ColorFilter.mode(
            context.color.brandSecondary, BlendMode.srcIn),
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
        Text(
          'Was this accurate?',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.color.textTertiary),
        ),
        const SizedBox(width: 8),
        const _ThumbButton(
            assetPath: 'assets/icons/feedback/positive.svg'),
        const _ThumbButton(
            assetPath: 'assets/icons/feedback/negative.svg'),
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
      borderRadius: BorderRadius.circular(_S.pillRadius),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          assetPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
              context.color.borderStrong, BlendMode.srcIn),
        ),
      ),
    );
  }
}
