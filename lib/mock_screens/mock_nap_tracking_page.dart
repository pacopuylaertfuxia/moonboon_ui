import 'dart:async';

import 'package:flutter/material.dart';

import '../common/button.dart';
import '../theme/theme_colors.dart';

/// Full-screen nap tracking view with live timer, collapse chevron, and stats.
class MockNapTrackingPage extends StatefulWidget {
  const MockNapTrackingPage({super.key});

  @override
  State<MockNapTrackingPage> createState() => _MockNapTrackingPageState();
}

class _MockNapTrackingPageState extends State<MockNapTrackingPage> {
  bool _isRunning = true;
  int _elapsedSeconds = 0;
  Timer? _timer;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRunning && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  void _togglePause() {
    setState(() => _isRunning = !_isRunning);
  }

  void _save() {
    Navigator.of(context).pop();
  }

  String get _formattedTime {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _napDurationLabel {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  String get _startTimeLabel {
    final hour = _startTime.hour;
    final minute = _startTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.surfaceSecondary,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildBody(context)),
            _buildButtons(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Collapse chevron
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.color.surfacePrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.color.textPrimary,
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Started $_startTimeLabel',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.color.textTertiary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nap emoji
        const Text('\u{1F4A4}', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),

        // Timer
        Text(
          _formattedTime,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 64,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
        ),
        const SizedBox(height: 8),

        // State label
        Text(
          _isRunning ? 'Napping...' : 'Paused',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.color.textTertiary,
              ),
        ),
        const SizedBox(height: 32),

        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _StatChip(
                  value: _napDurationLabel,
                  label: 'This nap',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  value: _isRunning ? 'Active' : 'Paused',
                  label: 'Status',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Button(
              variant: ButtonVariant.primary,
              size: ButtonSize.lg,
              onPressed: _save,
              buttonLabel: const Text('Save'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Button(
              variant: ButtonVariant.secondary,
              size: ButtonSize.lg,
              onPressed: _togglePause,
              buttonLabel: Text(_isRunning ? 'Pause' : 'Resume'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: context.color.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.color.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}
