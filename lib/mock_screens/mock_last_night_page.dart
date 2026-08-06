import 'package:flutter/material.dart';

import '../common/surface_card.dart';
import '../theme/theme_colors.dart';

// ── Data ─────────────────────────────────────────────────────────────────────

class NightSegment {
  final DateTime start;
  final DateTime end;
  final bool isSleep;
  final String? reason;

  const NightSegment({
    required this.start,
    required this.end,
    required this.isSleep,
    this.reason,
  });

  Duration get duration => end.difference(start);
}

class NightReport {
  final DateTime bedtime;
  final DateTime wakeTime;
  final List<NightSegment> segments;
  final int wakeCount;

  const NightReport({
    required this.bedtime,
    required this.wakeTime,
    required this.segments,
    required this.wakeCount,
  });

  Duration get totalNight => wakeTime.difference(bedtime);

  Duration get totalSleep => segments
      .where((s) => s.isSleep)
      .fold(Duration.zero, (sum, s) => sum + s.duration);

  Duration get longestStretch {
    var longest = Duration.zero;
    for (final s in segments) {
      if (s.isSleep && s.duration > longest) longest = s.duration;
    }
    return longest;
  }

  NightSegment? get longestStretchSegment {
    NightSegment? best;
    for (final s in segments) {
      if (s.isSleep && (best == null || s.duration > best.duration)) best = s;
    }
    return best;
  }

  Duration get avgWakeDuration {
    final wakes = segments.where((s) => !s.isSleep).toList();
    if (wakes.isEmpty) return Duration.zero;
    final total = wakes.fold(Duration.zero, (sum, s) => sum + s.duration);
    return Duration(milliseconds: total.inMilliseconds ~/ wakes.length);
  }
}

// ── Mock data ────────────────────────────────────────────────────────────────

final _mockReport = NightReport(
  bedtime: DateTime(2026, 6, 14, 20, 30),
  wakeTime: DateTime(2026, 6, 15, 6, 42),
  wakeCount: 2,
  segments: [
    NightSegment(
      start: DateTime(2026, 6, 14, 20, 30),
      end: DateTime(2026, 6, 15, 1, 15),
      isSleep: true,
    ),
    NightSegment(
      start: DateTime(2026, 6, 15, 1, 15),
      end: DateTime(2026, 6, 15, 1, 23),
      isSleep: false,
      reason: 'Hungry',
    ),
    NightSegment(
      start: DateTime(2026, 6, 15, 1, 23),
      end: DateTime(2026, 6, 15, 4, 50),
      isSleep: true,
    ),
    NightSegment(
      start: DateTime(2026, 6, 15, 4, 50),
      end: DateTime(2026, 6, 15, 5, 2),
      isSleep: false,
      reason: 'Fussy',
    ),
    NightSegment(
      start: DateTime(2026, 6, 15, 5, 2),
      end: DateTime(2026, 6, 15, 6, 42),
      isSleep: true,
    ),
  ],
);

final _mockPreviousReport = NightReport(
  bedtime: DateTime(2026, 6, 13, 21, 0),
  wakeTime: DateTime(2026, 6, 14, 6, 30),
  wakeCount: 3,
  segments: [],
);

// ── Page ─────────────────────────────────────────────────────────────────────

/// Shows the "Last night" card. Tap → detail sheet.
class MockLastNightPage extends StatelessWidget {
  const MockLastNightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.surfaceSecondary,
      appBar: AppBar(
        backgroundColor: context.color.surfacePrimary,
        foregroundColor: context.color.textPrimary,
        title: Text('Home', style: Theme.of(context).textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _LastNightCard(
              report: _mockReport,
              onTap: () => _showDetail(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: ctx.color.surfaceSecondary,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: _LastNightDetail(
            report: _mockReport,
            previousReport: _mockPreviousReport,
            scrollController: scrollController,
          ),
        ),
      ),
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _LastNightCard extends StatelessWidget {
  final NightReport report;
  final VoidCallback onTap;

  const _LastNightCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('\u{1F319}', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Last night',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                Text(
                  _fmtDuration(report.totalSleep),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Night bar
            _NightBar(segments: report.segments),
            const SizedBox(height: 8),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmtTime(report.bedtime),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.color.textTertiary,
                      ),
                ),
                Text(
                  '${report.wakeCount} wake${report.wakeCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.color.textTertiary,
                      ),
                ),
                Text(
                  _fmtTime(report.wakeTime),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.color.textTertiary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NightBar extends StatelessWidget {
  final List<NightSegment> segments;

  const _NightBar({required this.segments});

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();
    final totalMs =
        segments.fold<int>(0, (s, seg) => s + seg.duration.inMilliseconds);
    if (totalMs == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: segments.map((seg) {
            final flex =
                (seg.duration.inMilliseconds * 1000 ~/ totalMs).clamp(1, 1000);
            return Expanded(
              flex: flex,
              child: Container(
                color: seg.isSleep
                    ? context.color.brandPrimary
                    : context.color.surfaceSecondary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Detail sheet ─────────────────────────────────────────────────────────────

class _LastNightDetail extends StatelessWidget {
  final NightReport report;
  final NightReport? previousReport;
  final ScrollController scrollController;

  const _LastNightDetail({
    required this.report,
    this.previousReport,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.color.surfaceQuaternary,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text('Last night', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),

        // Stat cards
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    value: _fmtDuration(report.totalSleep),
                    label: 'Total sleep')),
            const SizedBox(width: 8),
            Expanded(
                child:
                    _StatCard(value: '${report.wakeCount}', label: 'Wakes')),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    value: _fmtDuration(report.longestStretch),
                    label: 'Longest stretch')),
          ],
        ),
        const SizedBox(height: 32),

        // Timeline header
        Text('Night timeline',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),

        // Timeline rows
        ...report.segments.map((seg) => _TimelineRow(
              time: _fmtTime(seg.start),
              label: seg.isSleep
                  ? '${_fmtDuration(seg.duration)} asleep'
                  : seg.reason ?? '${_fmtDuration(seg.duration)} awake',
              isSleep: seg.isSleep,
            )),

        // Good morning
        _TimelineRow(
          time: _fmtTime(report.wakeTime),
          label: 'Good morning',
          isSleep: true,
          isLast: true,
          icon: '\u{2600}\u{FE0F}',
        ),
        const SizedBox(height: 32),

        // Insights
        _InsightsSection(report: report, previousReport: previousReport),
      ],
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: context.color.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.color.textTertiary,
                  ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Timeline row ─────────────────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  final String time;
  final String label;
  final bool isSleep;
  final bool isLast;
  final String? icon;

  const _TimelineRow({
    required this.time,
    required this.label,
    required this.isSleep,
    this.isLast = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          SizedBox(
            width: 80,
            child: Text(
              icon != null ? '$icon $time' : time,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.color.textSecondary,
                  ),
            ),
          ),
          const SizedBox(width: 8),

          // Dot + line
          SizedBox(
            width: 10,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSleep ? context.color.brandPrimary : null,
                    border: isSleep
                        ? null
                        : Border.all(
                            color: context.color.textTertiary, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isSleep
                          ? context.color.brandPrimary
                          : context.color.borderSubdued,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Label
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSleep
                          ? context.color.textPrimary
                          : context.color.textTertiary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Insights ─────────────────────────────────────────────────────────────────

class _InsightsSection extends StatelessWidget {
  final NightReport report;
  final NightReport? previousReport;

  const _InsightsSection({required this.report, this.previousReport});

  @override
  Widget build(BuildContext context) {
    final insights = <String>[];

    final longest = report.longestStretchSegment;
    if (longest != null) {
      insights.add(
        'Longest stretch was ${_fmtDuration(longest.duration)} '
        '(${_fmtTime(longest.start)} \u{2192} ${_fmtTime(longest.end)})',
      );
    }

    if (previousReport != null) {
      final diff = previousReport!.wakeCount - report.wakeCount;
      if (diff > 0) {
        insights.add('$diff fewer wake${diff == 1 ? '' : 's'} than the night before');
      } else if (diff < 0) {
        insights.add('${diff.abs()} more wake${diff.abs() == 1 ? '' : 's'} than the night before');
      } else {
        insights.add('Same number of wakes as the night before');
      }
    }

    if (report.wakeCount > 0) {
      insights.add('Average wake lasted ${_fmtDuration(report.avgWakeDuration)}');
    }

    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Insights', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...insights.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\u{2022}  ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.color.textSecondary,
                          )),
                  Expanded(
                    child: Text(i,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.color.textSecondary,
                                )),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _fmtTime(DateTime dt) {
  final h = dt.hour;
  final m = dt.minute.toString().padLeft(2, '0');
  final period = h >= 12 ? 'PM' : 'AM';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return '$h12:$m $period';
}

String _fmtDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  if (m > 0) return '${m}m';
  return '0m';
}
