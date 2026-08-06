import 'dart:async';

import 'package:flutter/material.dart';

import '../common/button.dart';
import '../theme/theme_colors.dart';

/// Nap-in-progress screen — live timer, single "End nap" action.
/// Navigation: push from [BabySleepHomePage], pop on end.
class BabySleepNapPage extends StatefulWidget {
  final DateTime napStart;
  final void Function(Duration elapsed) onNapEnded;

  const BabySleepNapPage({
    super.key,
    required this.napStart,
    required this.onNapEnded,
  });

  @override
  State<BabySleepNapPage> createState() => _BabySleepNapPageState();
}

class _BabySleepNapPageState extends State<BabySleepNapPage> {
  static const String _keplerFamily = 'KeplerStd';
  static const double _timerFontSize = 72.0;

  late final Timer _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(widget.napStart);
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
  }

  void _endNap() {
    _ticker.cancel();
    widget.onNapEnded(DateTime.now().difference(widget.napStart));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Scaffold(
      backgroundColor: c.surfacePrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Close button ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded, color: c.textTertiary, size: 24),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // prototype: pending l10n
                  Text(
                    'Tommasino is sleeping',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: c.textTertiary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _formatElapsed(_elapsed),
                    style: TextStyle(
                      fontFamily: _keplerFamily,
                      fontSize: _timerFontSize,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 56),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Button(
                      buttonLabel: const Text('End nap'),
                      onPressed: _endNap,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.lg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
