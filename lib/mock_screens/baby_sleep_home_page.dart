import 'dart:async';

import 'package:flutter/material.dart';

import '../common/button.dart';
import '../common/surface_card.dart';
import '../theme/theme_colors.dart';
import 'baby_sleep_nap_page.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _SleepPeriod {
  final DateTime start;
  final DateTime end;

  const _SleepPeriod({required this.start, required this.end});

  Duration get duration => end.difference(start);

  String get durationLabel {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}

String _fmtTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _fmtDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

// ── Page ──────────────────────────────────────────────────────────────────────

/// Learning-phase home screen.
/// Hardcoded to Tommasino, 48 days old, Mon May 18th, with two seed naps.
class BabySleepHomePage extends StatefulWidget {
  const BabySleepHomePage({super.key});

  @override
  State<BabySleepHomePage> createState() => _BabySleepHomePageState();
}

class _BabySleepHomePageState extends State<BabySleepHomePage> {
  static const String _babyName = 'Tommasino';

  // Seed: nap 06:00–07:30, nap 09:00–10:15
  final List<_SleepPeriod> _naps = [
    _SleepPeriod(
      start: DateTime(2026, 5, 18, 6, 0),
      end: DateTime(2026, 5, 18, 7, 30),
    ),
    _SleepPeriod(
      start: DateTime(2026, 5, 18, 9, 0),
      end: DateTime(2026, 5, 18, 10, 15),
    ),
  ];

  DateTime _awakeSince = DateTime(2026, 5, 18, 10, 15);
  String? _feedConfirmation;
  Timer? _feedConfirmTimer;

  @override
  void dispose() {
    _feedConfirmTimer?.cancel();
    super.dispose();
  }

  void _startNap() {
    final napStart = DateTime.now();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BabySleepNapPage(
          napStart: napStart,
          onNapEnded: (elapsed) {
            final napEnd = napStart.add(elapsed);
            setState(() {
              _naps.add(_SleepPeriod(start: napStart, end: napEnd));
              _awakeSince = napEnd;
            });
          },
        ),
      ),
    );
  }

  void _showFeedSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FeedSheet(
        babyName: _babyName,
        onFeedLogged: (type) {
          Navigator.pop(ctx);
          _feedConfirmTimer?.cancel();
          setState(() => _feedConfirmation = 'Logged: $type');
          _feedConfirmTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => _feedConfirmation = null);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HomeHeader(babyName: _babyName),
              const SizedBox(height: 28),
              _PrimaryActions(
                onStartNap: _startNap,
                onLogFeed: _showFeedSheet,
                feedConfirmation: _feedConfirmation,
              ),
              const SizedBox(height: 28),
              _TimelineSection(babyName: _babyName, naps: _naps, awakeSince: _awakeSince),
              const SizedBox(height: 16),
              const _LearningInsightCard(babyName: _babyName),
              const SizedBox(height: 12),
              const _DailyGuidanceCard(),
              const SizedBox(height: 12),
              const _DualProgressCard(babyName: _babyName),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final String babyName;

  const _HomeHeader({required this.babyName});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // prototype: pending l10n
        Text(
          'Mon, May 18th',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: 6),
        // prototype: pending l10n
        Text(
          'Getting to know $babyName',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        // prototype: pending l10n
        Text(
          'Day 12 of learning their rhythm',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}

// ── Primary actions ───────────────────────────────────────────────────────────

class _PrimaryActions extends StatelessWidget {
  final VoidCallback onStartNap;
  final VoidCallback onLogFeed;
  final String? feedConfirmation;

  const _PrimaryActions({
    required this.onStartNap,
    required this.onLogFeed,
    this.feedConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // prototype: pending l10n
        Button(
          buttonLabel: const Text('Start nap'),
          onPressed: onStartNap,
          variant: ButtonVariant.primary,
          size: ButtonSize.lg,
        ),
        const SizedBox(height: 10),
        // prototype: pending l10n
        Button(
          buttonLabel: const Text('Log feed'),
          onPressed: onLogFeed,
          variant: ButtonVariant.outlined,
          size: ButtonSize.medium,
        ),
        if (feedConfirmation != null) ...[
          const SizedBox(height: 10),
          Text(
            feedConfirmation!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.feedbackSuccess,
                ),
          ),
        ],
      ],
    );
  }
}

// ── Timeline ──────────────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  final String babyName;
  final List<_SleepPeriod> naps;
  final DateTime awakeSince;

  const _TimelineSection({
    required this.babyName,
    required this.naps,
    required this.awakeSince,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // prototype: pending l10n
          Text(
            "$babyName's day so far",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 20),
          _SleepTimeline(naps: naps, awakeSince: awakeSince),
        ],
      ),
    );
  }
}

class _SleepTimeline extends StatelessWidget {
  final List<_SleepPeriod> naps;
  final DateTime awakeSince;

  const _SleepTimeline({required this.naps, required this.awakeSince});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    for (int i = 0; i < naps.length; i++) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 4));
      items.add(_NapPill(period: naps[i]));

      if (i < naps.length - 1) {
        final gap = naps[i + 1].start.difference(naps[i].end);
        items.add(_AwakeGap(label: '${_fmtDuration(gap)} awake'));
      }
    }

    if (naps.isNotEmpty) {
      items.add(_AwakeGap(
        // prototype: pending l10n
        label: 'Awake since ${_fmtTime(awakeSince)}',
        isCurrent: true,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }
}

class _NapPill extends StatelessWidget {
  final _SleepPeriod period;

  static const double _pxPerMin = 1.0;
  static const double _minPillHeight = 48.0;
  static const double _pillRadius = 14.0;

  const _NapPill({required this.period});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final pillHeight = (period.duration.inMinutes * _pxPerMin).clamp(_minPillHeight, 200.0);
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textTertiary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_fmtTime(period.start), style: labelStyle),
        const SizedBox(height: 3),
        Container(
          height: pillHeight,
          decoration: BoxDecoration(
            color: c.brandPrimary.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(_pillRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            period.durationLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textInverse),
          ),
        ),
        const SizedBox(height: 3),
        Text(_fmtTime(period.end), style: labelStyle, textAlign: TextAlign.right),
      ],
    );
  }
}

class _AwakeGap extends StatelessWidget {
  final String label;
  final bool isCurrent;

  const _AwakeGap({required this.label, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textTertiary);

    if (isCurrent) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(label, style: textStyle),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: c.borderNormal)),
          const SizedBox(width: 12),
          Text(label, style: textStyle),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: c.borderNormal)),
        ],
      ),
    );
  }
}

// ── Learning insight card ─────────────────────────────────────────────────────

class _LearningInsightCard extends StatelessWidget {
  final String babyName;

  const _LearningInsightCard({required this.babyName});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // prototype: pending l10n
          Text(
            'What we\'re learning',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: 12),
          // prototype: pending l10n
          Text(
            '$babyName seems to do best with wake windows around 70 minutes right now. '
            'A week ago they were closer to 60 — a sign their stamina is growing.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: c.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Daily guidance card ───────────────────────────────────────────────────────

class _DailyGuidanceCard extends StatelessWidget {
  static const List<String> _items = [
    // prototype: pending l10n
    'Get some morning daylight together',
    'Watch for tired signs',
    'Let the last wake window be a short one',
  ];

  const _DailyGuidanceCard();

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // prototype: pending l10n
          Text(
            'Today\'s gentle nudges',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: 14),
          ...List.generate(_items.length, (i) {
            final isLast = i == _items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: c.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _items[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: c.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Dual progress card ────────────────────────────────────────────────────────

class _DualProgressCard extends StatelessWidget {
  final String babyName;

  const _DualProgressCard({required this.babyName});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // prototype: pending l10n
          Text(
            "$babyName's rhythm is emerging",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: 18),
          // Body clock — 8 of 12 weeks
          // prototype: pending l10n
          const _ProgressRow(
            label: 'Body clock developing',
            valueLabel: '8 of 12 weeks',
            fraction: 8 / 12,
          ),
          const SizedBox(height: 14),
          // Sleep patterns — 14 of 21 days
          // prototype: pending l10n
          const _ProgressRow(
            label: 'Sleep patterns',
            valueLabel: '14 of 21 tracked days',
            fraction: 14 / 21,
          ),
          const SizedBox(height: 16),
          // prototype: pending l10n
          Text(
            'We\'ll suggest a personalized schedule once both are ready.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.textTertiary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final String valueLabel;
  final double fraction;

  static const double _barHeight = 6.0;
  static const double _barRadius = 3.0;

  const _ProgressRow({
    required this.label,
    required this.valueLabel,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary),
            ),
            Text(
              valueLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(_barRadius),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: _barHeight,
            backgroundColor: c.borderSubdued,
            valueColor: AlwaysStoppedAnimation<Color>(c.brandPrimary),
          ),
        ),
      ],
    );
  }
}

// ── Feed sheet ────────────────────────────────────────────────────────────────

class _FeedSheet extends StatelessWidget {
  final String babyName;
  final void Function(String feedType) onFeedLogged;

  static const List<String> _feedTypes = ['Breast', 'Bottle', 'Solids'];

  const _FeedSheet({required this.babyName, required this.onFeedLogged});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: c.surfaceSecondary,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // prototype: pending l10n
            Text(
              'Just fed $babyName?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 20),
            ...List.generate(_feedTypes.length, (i) {
              final type = _feedTypes[i];
              final isLast = i == _feedTypes.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                child: Button(
                  buttonLabel: Text(type),
                  onPressed: () => onFeedLogged(type),
                  variant: ButtonVariant.outlined,
                  size: ButtonSize.lg,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
