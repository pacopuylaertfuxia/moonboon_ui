import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../mock/mock_nap_cubit.dart';
import '../theme/theme_colors.dart';

/// Reusable nap card showing time range, duration pill, and source badge.
/// Source badge indicates whether the nap was started manually, via the
/// motor, or auto-detected by the monitor.
class NapCard extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final NapSource source;
  final VoidCallback? onDelete;

  const NapCard({
    super.key,
    required this.start,
    required this.end,
    this.source = NapSource.manual,
    this.onDelete,
  });

  Duration get _duration => end.difference(start);

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    if (m > 0) return '${m}m';
    return '< 1m';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.borderNormal),
      ),
      child: Row(
        children: [
          // Source badge
          _SourceBadge(source: source, c: c),
          const SizedBox(width: 12),
          // Time range
          Expanded(
            child: Text(
              '${_formatTime(start)} – ${_formatTime(end)}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary),
            ),
          ),
          // Duration pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c.surfaceTertiary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              _formatDuration(_duration),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final NapSource source;
  final ThemeColors c;
  const _SourceBadge({required this.source, required this.c});

  String get _icon => switch (source) {
        NapSource.motor   => 'assets/icons/controls/replay.svg',
        NapSource.monitor => 'assets/icons/controls/camera.svg',
        NapSource.manual  => 'assets/icons/utility/edit.svg',
      };

  String get _tooltip => switch (source) {
        NapSource.motor   => 'Started by motor',
        NapSource.monitor => 'Detected by monitor',
        NapSource.manual  => 'Logged manually',
      };

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _tooltip,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: c.surfaceSecondary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            _icon,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(c.brandSecondary, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
