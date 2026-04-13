import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../mock/mock_nap_cubit.dart';
import '../theme/theme_colors.dart';

/// Daily sleep summary — total, goal progress, stat chips, educational insight.
/// Designed to expand later for feeds, temperature, and other trackables.
class TrackSummaryCard extends StatelessWidget {
  final List<MockNap> naps;
  final DateTime? activeNapStart;
  final DateTime now;

  /// Daily sleep goal. Defaults to 3 hours — will come from user settings.
  final Duration goal;

  const TrackSummaryCard({
    super.key,
    required this.naps,
    required this.now,
    this.activeNapStart,
    this.goal = const Duration(hours: 3),
  });

  Duration get _completed =>
      naps.fold(Duration.zero, (acc, n) => acc + n.duration);

  Duration get _active =>
      activeNapStart == null ? Duration.zero : now.difference(activeNapStart!);

  Duration get _total => _completed + _active;

  double get _progress => (_total.inSeconds / goal.inSeconds).clamp(0.0, 1.0);

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    if (m > 0) return '${m}m';
    return '< 1m';
  }

  String get _insight {
    final count = naps.length + (activeNapStart != null ? 1 : 0);
    if (count == 0) return 'Most babies nap 3–5 times a day. Tap "Start nap" when baby goes down.';
    if (_progress >= 1.0) return 'Goal reached! Consistent sleep builds healthy brain development.';
    if (_progress >= 0.5) return 'On track. Regular naps support memory consolidation and growth hormones.';
    return 'Shorter naps are normal early on. Watch for tired cues — rubbing eyes, yawning.';
  }

  String get _goalLabel {
    final pct = (_progress * 100).round();
    return 'Goal: ${_fmt(goal)} · $pct%';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final napCount = naps.length + (activeNapStart != null ? 1 : 0);
    final avgDuration = napCount > 0
        ? Duration(minutes: _total.inMinutes ~/ napCount)
        : Duration.zero;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.borderNormal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/utility/moon.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                'Sleep today',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary),
              ),
              const Spacer(),
              Text(
                _goalLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Big total ────────────────────────────────────────────────────────
          Text(
            _total == Duration.zero ? '—' : _fmt(_total),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: c.textPrimary,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 10),

          // ── Progress bar ─────────────────────────────────────────────────────
          _ProgressBar(progress: _progress, c: c),
          const SizedBox(height: 16),

          // ── Stat chips ───────────────────────────────────────────────────────
          Row(
            children: [
              _StatChip(
                value: '$napCount',
                label: napCount == 1 ? 'nap' : 'naps',
                c: c,
                context: context,
              ),
              const SizedBox(width: 8),
              if (napCount > 0) ...[
                _StatChip(
                  value: _fmt(avgDuration),
                  label: 'avg',
                  c: c,
                  context: context,
                ),
                const SizedBox(width: 8),
              ],
              _StatChip(
                value: _fmt(goal - _total > Duration.zero ? goal - _total : Duration.zero),
                label: _progress >= 1.0 ? 'goal ✓' : 'to goal',
                c: c,
                context: context,
                highlight: _progress >= 1.0,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Insight ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: c.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _insight,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary),
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: c.surfaceTertiary,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              width: (w * progress).clamp(0.0, w),
              height: 6,
              decoration: BoxDecoration(
                color: progress >= 1.0 ? c.feedbackSuccess : c.brandPrimary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final ThemeColors c;
  final BuildContext context;
  final bool highlight;

  const _StatChip({
    required this.value,
    required this.label,
    required this.c,
    required this.context,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? c.feedbackSuccess.withValues(alpha: 0.12) : c.surfaceSecondary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: highlight ? c.feedbackSuccess : c.textPrimary,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}
