import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/button.dart';
import '../common/device_context_chip.dart';
import '../common/mock_bottom_nav.dart';
import '../common/nap_card.dart';
import '../common/nap_day_timeline.dart';
import '../common/track_summary_card.dart';
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
    final c = context.color;
    final topPadding = MediaQuery.of(context).padding.top;
    final barHeight = topPadding + kToolbarHeight;

    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(barHeight),
        child: _BlurredDateNav(state: state),
      ),
      body: Stack(
        children: [
          _NapBody(state: state, topOffset: barHeight),
          _FloatingCta(state: state),
        ],
      ),
      bottomNavigationBar: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [MockBottomNav(activeIndex: 1)],
      ),
    );
  }
}

// ── Blurred date navigation app bar ──────────────────────────────────────────

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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: barHeight,
          width: double.infinity,
          color: c.surfaceSecondary.withValues(alpha: 0.85),
          padding: EdgeInsets.only(top: topPadding),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.read<MockNapCubit>().goToPreviousDay(),
                  icon: SvgPicture.asset(
                    'assets/icons/utility/chevron_left.svg',
                    colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
                    width: 18,
                    height: 18,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () => Navigator.of(context).pop(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dateDisplay(state.selectedDate),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textPrimary),
                        ),
                        if (_dateSubLabel(state.selectedDate).isNotEmpty)
                          Text(
                            _dateSubLabel(state.selectedDate),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textTertiary),
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: state.isAtToday
                      ? null
                      : () => context.read<MockNapCubit>().goToNextDay(),
                  icon: SvgPicture.asset(
                    'assets/icons/utility/chevron_right.svg',
                    colorFilter: ColorFilter.mode(
                      state.isAtToday ? c.textInactive : c.textPrimary,
                      BlendMode.srcIn,
                    ),
                    width: 18,
                    height: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    // Clear the floating CTA area + nav pill
    final bottomClearance = mockNavBarTotalHeight(context) + 88;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topOffset + 16)),

        // ── Day timeline ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: NapDayTimeline(
              naps: naps,
              activeNapStart: state.activeNapStart,
              now: state.now,
            ),
          ),
        ),

        // ── Active nap card ─────────────────────────────────────────────────
        if (state.activeNapStart != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _ActiveNapCard(state: state),
            ),
          ),

        // ── Summary card ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TrackSummaryCard(
              naps: naps,
              activeNapStart: state.activeNapStart,
              now: state.now,
            ),
          ),
        ),

        // ── Section header ──────────────────────────────────────────────────
        if (naps.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Naps',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.color.textTertiary,
                    ),
              ),
            ),
          ),

        // ── Nap list ────────────────────────────────────────────────────────
        if (naps.isNotEmpty)
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
          )
        else if (state.activeNapStart == null)
          SliverToBoxAdapter(child: _EmptyState()),

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
    final startTime = _formatTime(state.activeNapStart!);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.borderNormal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          // Header row
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/controls/pause.svg',
                colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Napping since $startTime',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary),
              ),
              const Spacer(),
              // Live Activity indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: c.surfaceSecondary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.feedbackSuccess,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Live',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: c.textTertiary,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Timer
          Text(
            _formatTimer(elapsed),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: c.textPrimary,
                  letterSpacing: 0,
                ),
            textAlign: TextAlign.center,
          ),
          // Stop button
          Button(
            onPressed: () => context.read<MockNapCubit>().stopNap(),
            buttonLabel: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/controls/stop.svg',
                  colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 8),
                Text('Stop nap', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            variant: ButtonVariant.secondary,
            size: ButtonSize.medium,
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
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/feedback/face_neutral.svg',
            colorFilter: ColorFilter.mode(c.textInactive, BlendMode.srcIn),
            width: 32,
            height: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'No naps logged yet',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Start nap" when your baby goes down,\nor link an active motor session below.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Floating CTA area (device chip + start button) ────────────────────────────

class _FloatingCta extends StatelessWidget {
  final MockNapState state;
  const _FloatingCta({required this.state});

  @override
  Widget build(BuildContext context) {
    final navBottom = mockNavBarTotalHeight(context);
    final hasDevice = state.isMotorRunning || state.isMonitorActive;
    final napActive = state.activeNapStart != null;

    // Nothing to show if a nap is already running and no device chip
    if (napActive && !hasDevice) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: navBottom + 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Device context chip
          if (hasDevice) ...[
            DeviceContextChip(
              isMotorRunning: state.isMotorRunning,
              isMonitorActive: state.isMonitorActive,
              onStartNap: napActive
                  ? null
                  : () => context.read<MockNapCubit>().startNap(
                        source: state.isMotorRunning ? NapSource.motor : NapSource.monitor,
                      ),
            ),
            const SizedBox(height: 8),
          ],
          // Start nap pill (hidden when nap active)
          if (!napActive)
            SizedBox(
              width: mockNavBarWidth,
              child: Button(
                onPressed: () => context.read<MockNapCubit>().startNap(),
                buttonLabel: Text(
                  'Start nap',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                variant: ButtonVariant.primary,
                size: ButtonSize.lg,
              ),
            ),
        ],
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
