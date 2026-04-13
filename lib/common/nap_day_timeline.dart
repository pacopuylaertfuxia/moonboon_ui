import 'package:flutter/material.dart';

import '../mock/mock_nap_cubit.dart';
import '../theme/theme_colors.dart';

/// Horizontal 6 am – 10 pm strip showing all nap blocks for a day.
/// Pass [naps] for completed naps, [activeNapStart] + [now] for the live block.
class NapDayTimeline extends StatelessWidget {
  final List<MockNap> naps;
  final DateTime? activeNapStart;
  final DateTime now;

  static const int _startHour = 6;
  static const int _endHour = 22;
  static const int _totalMinutes = (_endHour - _startHour) * 60; // 960

  const NapDayTimeline({
    super.key,
    required this.naps,
    required this.now,
    this.activeNapStart,
  });

  double _fraction(DateTime dt) {
    final minutes = dt.hour * 60 + dt.minute - _startHour * 60;
    return (minutes / _totalMinutes).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Bar ───────────────────────────────────────────────────────────────
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: c.surfacePrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.borderSubdued),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final nowFraction = _fraction(now);

                return Stack(
                  children: [
                    // Completed nap blocks
                    for (final nap in naps)
                      _NapBlock(
                        left: _fraction(nap.start) * w,
                        width: (_fraction(nap.end) - _fraction(nap.start)) * w,
                        color: c.brandPrimary.withValues(alpha: 0.65),
                      ),
                    // Active nap block
                    if (activeNapStart != null)
                      _NapBlock(
                        left: _fraction(activeNapStart!) * w,
                        width: (nowFraction - _fraction(activeNapStart!)).clamp(0.0, 1.0) * w,
                        color: c.brandPrimary.withValues(alpha: 0.3),
                      ),
                    // Current-time cursor
                    Positioned(
                      left: (nowFraction * w - 1).clamp(0.0, w - 2),
                      top: 8,
                      bottom: 8,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: c.brandSecondary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 5),
        // ── Time labels ───────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TimeLabel('6 am', c),
            _TimeLabel('12 pm', c),
            _TimeLabel('6 pm', c),
            _TimeLabel('10 pm', c),
          ],
        ),
      ],
    );
  }
}

class _NapBlock extends StatelessWidget {
  final double left;
  final double width;
  final Color color;
  const _NapBlock({required this.left, required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    if (width <= 0) return const SizedBox.shrink();
    return Positioned(
      left: left,
      width: width.clamp(4.0, double.infinity),
      top: 8,
      bottom: 8,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String text;
  final ThemeColors c;
  const _TimeLabel(this.text, this.c);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: c.textInactive,
            fontSize: 10,
          ),
    );
  }
}
