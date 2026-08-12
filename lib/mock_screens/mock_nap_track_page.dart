import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/button.dart';
import '../common/daily_photos_card.dart';
import '../common/mock_bottom_nav.dart';
import '../common/modal_sheet.dart';
import '../common/nap_card.dart';
import '../common/nap_day_timeline.dart';
import '../mock/mock_nap_cubit.dart';
import '../theme/theme_colors.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class MockNapTrackPage extends StatelessWidget {
  const MockNapTrackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MockNapCubit(),
      child: const _NapScaffold(),
    );
  }
}

// ── Scaffold ──────────────────────────────────────────────────────────────────

class _NapScaffold extends StatelessWidget {
  const _NapScaffold();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MockNapCubit>().state;
    final topPadding = MediaQuery.of(context).padding.top;
    final barHeight = topPadding + kToolbarHeight;

    return Scaffold(
      backgroundColor: context.color.surfaceSecondary,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(barHeight),
        child: _BlurredDateNav(state: state),
      ),
      body: _NapBody(state: state, topOffset: barHeight),
      bottomNavigationBar: _BottomArea(state: state),
    );
  }
}

// ── Bottom area — nav pill + centered FAB above Track tab ─────────────────────

class _BottomArea extends StatelessWidget {
  final MockNapState state;
  const _BottomArea({required this.state});

  static const double _fabSize = 54;
  static const double _fabGap = 10;

  static double totalHeight(BuildContext context) =>
      mockNavBarTotalHeight(context) + _fabSize + _fabGap;

  @override
  Widget build(BuildContext context) {
    final napActive = state.activeNapStart != null;
    final navTotal = mockNavBarTotalHeight(context);
    final c = context.color;

    return SizedBox(
      height: totalHeight(context),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Nav pill
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [MockBottomNav(activeIndex: 1)],
            ),
          ),
          // FAB centered above the Track (center) tab
          Positioned(
            bottom: navTotal + _fabGap,
            child: AnimatedScale(
              scale: napActive ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: napActive ? null : () => _openTrackingSheet(context, state),
                child: Container(
                  width: _fabSize,
                  height: _fabSize,
                  decoration: BoxDecoration(
                    color: c.brandPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: c.brandPrimary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.add_rounded, color: c.textInverse, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _openTrackingSheet(BuildContext context, MockNapState state) {
  final cubit = context.read<MockNapCubit>();
  ModalSheet.show(
    context: context,
    hasPadding: false,
    duration: Duration.zero,
    background: ModalSheetBackground.cream,
    child: _TrackingOptionsSheet(
      onStartNap: () {
        Navigator.of(context).pop();
        cubit.startNap(
          source: state.isMotorRunning
              ? NapSource.motor
              : state.isMonitorActive
                  ? NapSource.monitor
                  : NapSource.manual,
        );
      },
    ),
  );
}

// ── Tracking options sheet ────────────────────────────────────────────────────

class _TrackingOptionsSheet extends StatelessWidget {
  final VoidCallback onStartNap;
  const _TrackingOptionsSheet({required this.onStartNap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'What would you like to track?',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap an entry to start logging.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: 16),
          _TrackOption(
            icon: SvgPicture.asset(
              'assets/icons/utility/moon-outline.svg',
              width: 22, height: 22,
              colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
            ),
            label: 'Nap',
            sub: 'Log a sleep session',
            onTap: onStartNap,
            c: c,
          ),
          _TrackOption(
            icon: Icon(Icons.water_drop_outlined, size: 22, color: c.textInactive),
            label: 'Feed',
            sub: 'Breast, bottle or solids',
            onTap: null,
            c: c,
          ),
          _TrackOption(
            icon: Icon(Icons.baby_changing_station_outlined, size: 22, color: c.textInactive),
            label: 'Diaper',
            sub: 'Wet or dirty',
            onTap: null,
            c: c,
          ),
          _TrackOption(
            icon: Icon(Icons.child_care_outlined, size: 22, color: c.textInactive),
            label: 'Play time',
            sub: 'Floor time, outdoor, tummy time',
            onTap: null,
            c: c,
          ),
          _TrackOption(
            icon: Icon(Icons.opacity_outlined, size: 22, color: c.textInactive),
            label: 'Pump',
            sub: 'Breast pump session',
            onTap: null,
            c: c,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TrackOption extends StatelessWidget {
  final Widget icon;
  final String label;
  final String sub;
  final VoidCallback? onTap;
  final ThemeColors c;
  final bool isLast;

  const _TrackOption({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    required this.c,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                SizedBox(width: 36, child: icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: enabled ? c.textPrimary : c.textInactive,
                        ),
                      ),
                      Text(
                        sub,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: enabled ? c.textTertiary : c.textInactive,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!enabled)
                  Text(
                    'Soon',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: c.textInactive,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, thickness: 1, color: c.borderSubdued),
      ],
    );
  }
}

// ── Blurred date navigation ───────────────────────────────────────────────────

class _BlurredDateNav extends StatelessWidget {
  final MockNapState state;
  const _BlurredDateNav({required this.state});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final topPadding = MediaQuery.of(context).padding.top;
    final barHeight = topPadding + kToolbarHeight;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: barHeight,
          width: double.infinity,
          color: c.surfaceSecondary.withValues(alpha: 0.88),
          padding: EdgeInsets.only(top: topPadding),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                _NavArrow(
                  icon: 'assets/icons/utility/chevron_left.svg',
                  enabled: true,
                  onTap: () => context.read<MockNapCubit>().goToPreviousDay(),
                ),
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dateDisplay(state.selectedDate),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: c.textPrimary),
                        ),
                        if (_dateSubLabel(state.selectedDate).isNotEmpty)
                          Text(
                            _dateSubLabel(state.selectedDate),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: c.textTertiary, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                ),
                _NavArrow(
                  icon: 'assets/icons/utility/chevron_right.svg',
                  enabled: !state.isAtToday,
                  onTap: () => context.read<MockNapCubit>().goToNextDay(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final String icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: SvgPicture.asset(
        icon,
        colorFilter: ColorFilter.mode(
          enabled ? c.textSecondary : c.textInactive,
          BlendMode.srcIn,
        ),
        width: 18,
        height: 18,
      ),
    );
  }
}

// ── Scrollable body ───────────────────────────────────────────────────────────

class _NapBody extends StatelessWidget {
  final MockNapState state;
  final double topOffset;
  const _NapBody({required this.state, required this.topOffset});

  @override
  Widget build(BuildContext context) {
    final naps = state.napsForDate;
    final bottomClearance = _BottomArea.totalHeight(context) + 24;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topOffset + 20)),

        // ── Timeline ─────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: NapDayTimeline(
              naps: naps,
              activeNapStart: state.activeNapStart,
              now: state.now,
            ),
          ),
        ),

        // ── Daily photos — lives directly under the timeline ─────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DailyPhotosCard(
              photos: state.photosForDate,
              onAddPhoto: () async {
                final bytes = await pickBabyPhoto(context);
                if (bytes != null && context.mounted) {
                  context.read<MockNapCubit>().addPhoto(bytes);
                }
              },
            ),
          ),
        ),

        // ── Active nap card ──────────────────────────────────────────────────
        if (state.activeNapStart != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _ActiveNapCard(state: state),
            ),
          ),

        // ── Device session context (inline, not floating) ────────────────────
        if (state.activeNapStart == null &&
            (state.isMotorRunning || state.isMonitorActive))
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _DeviceSessionCard(
                isMotor: state.isMotorRunning,
                onLog: () => context.read<MockNapCubit>().startNap(
                      source: state.isMotorRunning
                          ? NapSource.motor
                          : NapSource.monitor,
                    ),
              ),
            ),
          ),

        // ── Sleep summary ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _SleepSummary(
              naps: naps,
              activeNapStart: state.activeNapStart,
              now: state.now,
            ),
          ),
        ),

        // ── Nap list ─────────────────────────────────────────────────────────
        if (naps.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                'Naps',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.color.textTertiary,
                      letterSpacing: 0.4,
                    ),
              ),
            ),
          ),
          SliverList.separated(
            itemCount: naps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: NapCard(
                start: naps[i].start,
                end: naps[i].end,
                source: naps[i].source,
              ),
            ),
          ),
        ] else if (state.activeNapStart == null)
          const SliverToBoxAdapter(child: _EmptyState()),

        SliverToBoxAdapter(child: SizedBox(height: bottomClearance)),
      ],
    );
  }
}

// ── Active nap card ───────────────────────────────────────────────────────────

class _ActiveNapCard extends StatelessWidget {
  final MockNapState state;
  const _ActiveNapCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final elapsed = state.activeNapDuration;
    final source = state.activeNapSource;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.borderNormal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Meta row ────────────────────────────────────────────────────────
          Row(
            children: [
              _DeviceIcon(source: source, c: c),
              const SizedBox(width: 6),
              Text(
                '${_sourceLabel(source)} · since ${_formatTime(state.activeNapStart!)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textTertiary),
              ),
              const Spacer(),
              _LiveBadge(c: c, context: context),
            ],
          ),

          // ── Timer ───────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              _formatTimer(elapsed),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: c.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Stop button ─────────────────────────────────────────────────────
          Button(
            onPressed: () => context.read<MockNapCubit>().stopNap(),
            buttonLabel: Text(
              'Stop nap',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textPrimary),
            ),
            variant: ButtonVariant.secondary,
            size: ButtonSize.standard,
          ),
        ],
      ),
    );
  }

  String _sourceLabel(NapSource source) => switch (source) {
        NapSource.motor   => 'Via motor',
        NapSource.monitor => 'Via monitor',
        NapSource.manual  => 'Manual',
      };
}

class _DeviceIcon extends StatelessWidget {
  final NapSource source;
  final ThemeColors c;
  const _DeviceIcon({required this.source, required this.c});

  @override
  Widget build(BuildContext context) {
    final icon = switch (source) {
      NapSource.motor   => 'assets/icons/controls/replay.svg',
      NapSource.monitor => 'assets/icons/controls/camera.svg',
      NapSource.manual  => 'assets/icons/utility/edit.svg',
    };
    return SvgPicture.asset(
      icon,
      colorFilter: ColorFilter.mode(c.brandPrimary, BlendMode.srcIn),
      width: 16,
      height: 16,
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final ThemeColors c;
  final BuildContext context;
  const _LiveBadge({required this.c, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.feedbackSuccess.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(c: c),
          const SizedBox(width: 5),
          Text(
            'Live',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: c.feedbackSuccess, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Device session card (embedded — shows when devices active, no nap yet) ────

class _DeviceSessionCard extends StatelessWidget {
  final bool isMotor;
  final VoidCallback onLog;
  const _DeviceSessionCard({required this.isMotor, required this.onLog});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final icon = isMotor
        ? 'assets/icons/controls/replay.svg'
        : 'assets/icons/controls/camera.svg';
    final label = isMotor ? 'Motor is running' : 'Monitor is active';
    final sub = isMotor
        ? 'Your baby might be napping — log it now'
        : 'Monitor is detecting sound — log a nap if baby is sleeping';

    return Container(
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.borderSubdued),
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: c.brandPrimary,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Icon
          SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(c.brandPrimary, BlendMode.srcIn),
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 10),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: c.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Log button
          GestureDetector(
            onTap: onLog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: c.brandPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Log nap',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: c.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sleep summary (compact) ───────────────────────────────────────────────────

class _SleepSummary extends StatelessWidget {
  final List<MockNap> naps;
  final DateTime? activeNapStart;
  final DateTime now;

  static const Duration _goal = Duration(hours: 3);

  const _SleepSummary({
    required this.naps,
    required this.activeNapStart,
    required this.now,
  });

  Duration get _completed =>
      naps.fold(Duration.zero, (acc, n) => acc + n.duration);

  Duration get _active =>
      activeNapStart == null ? Duration.zero : now.difference(activeNapStart!);

  Duration get _total => _completed + _active;
  int get _napCount => naps.length + (activeNapStart != null ? 1 : 0);
  double get _progress => (_total.inSeconds / _goal.inSeconds).clamp(0.0, 1.0);

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    if (m > 0) return '${m}m';
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final avgDuration = _napCount > 0
        ? Duration(minutes: _total.inMinutes ~/ _napCount)
        : Duration.zero;
    final remaining = _goal - _total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.borderSubdued),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sleep today',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: c.textTertiary,
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _total == Duration.zero ? '—' : _fmt(_total),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: c.textPrimary,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              if (_progress >= 1.0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: c.feedbackSuccess.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Goal ✓',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: c.feedbackSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar
          _ProgressBar(progress: _progress, c: c),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Goal: ${_fmt(_goal)}',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: c.textInactive, fontSize: 10),
              ),
              Text(
                _progress >= 1.0
                    ? 'Done!'
                    : '${_fmt(remaining)} to go',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: c.textInactive, fontSize: 10),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stat chips
          Row(
            children: [
              _Chip(
                label: '$_napCount',
                sub: _napCount == 1 ? 'nap' : 'naps',
                c: c,
                context: context,
              ),
              const SizedBox(width: 8),
              if (_napCount > 0) ...[
                _Chip(
                  label: _fmt(avgDuration),
                  sub: 'avg',
                  c: c,
                  context: context,
                ),
                const SizedBox(width: 8),
              ],
              _Chip(
                label: '${(_progress * 100).round()}%',
                sub: 'of goal',
                c: c,
                context: context,
                highlight: _progress >= 1.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final ThemeColors c;
  const _ProgressBar({required this.progress, required this.c});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(height: 6, color: c.surfaceSecondary),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                height: 6,
                width: constraints.maxWidth * progress,
                color: progress >= 1.0 ? c.feedbackSuccess : c.brandPrimary,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String sub;
  final ThemeColors c;
  final BuildContext context;
  final bool highlight;

  const _Chip({
    required this.label,
    required this.sub,
    required this.c,
    required this.context,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: highlight
            ? c.feedbackSuccess.withValues(alpha: 0.1)
            : c.surfaceSecondary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: highlight ? c.feedbackSuccess : c.textPrimary,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            sub,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/utility/moon.svg',
            colorFilter: ColorFilter.mode(c.textInactive, BlendMode.srcIn),
            width: 28,
            height: 28,
          ),
          const SizedBox(height: 12),
          Text(
            'No naps logged',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to start tracking',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c.textInactive),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Pulsing dot (shared) ──────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  final ThemeColors c;
  const _PulseDot({required this.c});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.c.feedbackSuccess
              .withValues(alpha: 0.5 + _anim.value * 0.5),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _formatTimer(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (h > 0) return '${h}h ${m}m ${s}s';
  return '${m}m ${s}s';
}

String _dateDisplay(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${months[d.month - 1]} ${d.day}';
}

String _dateSubLabel(DateTime d) {
  final today = _todayMidnight();
  if (d == today) return 'Today';
  if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '';
}

DateTime _todayMidnight() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}
