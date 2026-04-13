import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../mock/mock_nap_cubit.dart';
import '../theme/theme_colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.borderSubdued),
      ),
      child: Row(
        children: [
          // Source badge
          _SourceBadge(source: source, c: c),
          const SizedBox(width: 12),
          // Time range + duration stacked
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatTime(start)} – ${_formatTime(end)}',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  _sourceLabel(source),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: c.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
          // Duration pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.surfaceSecondary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              _formatDuration(_duration),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  String _sourceLabel(NapSource source) => switch (source) {
        NapSource.motor   => 'Via motor',
        NapSource.monitor => 'Via monitor',
        NapSource.manual  => 'Logged manually',
      };
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: c.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: SvgPicture.asset(
          _icon,
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(c.brandPrimary, BlendMode.srcIn),
        ),
      ),
    );
  }
}
