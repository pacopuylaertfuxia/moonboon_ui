import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'live_activity_cubit.dart';
import 'live_activity_state.dart';
import 'native_video_player.dart';

// Palette
const _bg      = Color(0xFF0F0D0B);
const _surface = Color(0xFF1E1A16);
const _card    = Color(0xFF2E2820);
const _sec     = Color(0xFFC4AA8E);
const _ter     = Color(0xFF8C8178);
const _green   = Color(0xFF34C759);
const _red     = Color(0xFFFF3B30);
const _clay    = Color(0xFFB59E85);
const _grey    = Color(0xFF3D352C);

class LiveActivityPlayground extends StatelessWidget {
  const LiveActivityPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocBuilder<LiveActivityCubit, LiveActivityState>(
        builder: (ctx, state) {
          final cubit = ctx.read<LiveActivityCubit>();
          final isCrying = state.soundLevel > 0.15;
          return Column(
            children: [
              // ── Video ─────────────────────────────────────────────────────
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const NativeVideoPlayer(),
                    // Audio bars overlay — only visible when sound detected
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedOpacity(
                        opacity: isCrying ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: _WaveformOverlay(level: state.soundLevel),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Controls ──────────────────────────────────────────────────
              Expanded(
                flex: 4,
                child: _ControlsSection(state: state, cubit: cubit),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Waveform overlay on video ──────────────────────────────────────────────

class _WaveformOverlay extends StatelessWidget {
  final double level;
  const _WaveformOverlay({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xCC0F0D0B), Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(24, (i) {
          final personalities = [
            0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.4, 1.0, 0.5, 0.7,
            0.8, 0.4, 0.9, 0.6, 0.5, 0.7, 1.0, 0.4, 0.8, 0.6,
            0.5, 0.9, 0.7, 0.4,
          ];
          final w = personalities[i];
          final h = (2.0 + w * 4.0 + level * w * 28.0).clamp(2.0, 34.0);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: h,
              decoration: BoxDecoration(
                color: _clay.withValues(alpha: 0.4 + level * 0.5),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Controls section ──────────────────────────────────────────────────────

class _ControlsSection extends StatelessWidget {
  final LiveActivityState state;
  final LiveActivityCubit cubit;
  const _ControlsSection({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [

          // ── Monitor activities ────────────────────────────────────────
          _SectionHeader('Monitor Activity'),
          _MonitorVariantRow(
            label: 'Monitor A',
            subtitle: 'Camera · monitor icon · photo',
            active: state.monitorActive,
            onStart: cubit.startMonitorA,
            onEnd: cubit.endMonitorA,
          ),
          const SizedBox(height: 8),
          _MonitorVariantRow(
            label: 'Monitor B',
            subtitle: 'Sensor · moon icon · metrics',
            active: state.monitorActiveB,
            onStart: cubit.startMonitorB,
            onEnd: cubit.endMonitorB,
          ),
          if (state.monitorActive || state.monitorActiveB) ...[
            const SizedBox(height: 8),
            _AudioSimButton(
              active: state.isSimulatingAudio,
              onTap: cubit.toggleAudioSimulation,
            ),
          ],
          const SizedBox(height: 12),

          // ── Motor activity ────────────────────────────────────────────
          _SectionHeader('Motor Activity'),
          _ActivityRow(
            label: 'Moonboon Motor',
            subtitle: state.motorRunning
                ? '${state.motorProgram} · speed ${state.motorSpeed}'
                : 'Off',
            active: state.motorActive,
            onStart: cubit.startMotor,
            onEnd: cubit.endMotor,
          ),
          const SizedBox(height: 16),

          // ── Shared: End All ───────────────────────────────────────────
          if (state.monitorActive || state.monitorActiveB || state.motorActive)
            _EndAllButton(onTap: cubit.endAll),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFF2E2820)),
          const SizedBox(height: 12),

          // ── Monitor controls ──────────────────────────────────────────
          _SectionHeader('Monitor Controls'),
          _SliderRow(
            label: 'Sound',
            value: state.soundLevel,
            onChanged: cubit.setSoundLevel,
          ),
          const SizedBox(height: 8),
          _CycleRow(
            label: 'Status',
            value: state.statusLabel,
            onCycle: cubit.cycleStatus,
          ),
          const SizedBox(height: 8),
          _StepRow(
            label: 'Temp',
            value: '${state.temperature ?? '--'}°C',
            onMinus: () => cubit.setTemperature((state.temperature ?? 20) - 1),
            onPlus:  () => cubit.setTemperature((state.temperature ?? 20) + 1),
          ),
          const SizedBox(height: 8),
          _StepRow(
            label: 'Battery',
            value: '${state.monitorBattery}%',
            onMinus: () => cubit.setMonitorBattery(state.monitorBattery - 10),
            onPlus:  () => cubit.setMonitorBattery(state.monitorBattery + 10),
          ),
          const SizedBox(height: 20),

          // ── Motor controls ────────────────────────────────────────────
          _SectionHeader('Motor Controls'),
          _CycleRow(
            label: 'Program',
            value: state.motorProgram,
            onCycle: cubit.cycleMotorProgram,
          ),
          const SizedBox(height: 8),
          _StepRow(
            label: 'Speed',
            value: '${state.motorSpeed}/10',
            onMinus: () => cubit.setMotorSpeed(state.motorSpeed - 1),
            onPlus:  () => cubit.setMotorSpeed(state.motorSpeed + 1),
          ),
          const SizedBox(height: 8),
          _ToggleRow(
            label: 'Motor',
            active: state.motorRunning,
            onToggle: cubit.toggleMotorRunning,
          ),
          const SizedBox(height: 20),

          // ── Auto-loop ─────────────────────────────────────────────────
          _AutoLoopButton(active: state.isAutoLooping, onTap: cubit.toggleAutoLoop),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFF2E2820)),
          const SizedBox(height: 12),

          // ── Notifications demo ────────────────────────────────────────
          _SectionHeader('Push Notifications (demo)'),
          ..._kNotifications.map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _NotificationRow(
              title: n['title']!,
              body:  n['body']!,
              onFire: () => cubit.fireNotification(n['title']!, n['body']!),
            ),
          )),
        ],
      ),
    );
  }
}

// Notification demo data — copy mirrors Moonboon FCM payload content
const _kNotifications = [
  {
    'title': 'Sound detected \u{1F50A}',
    'body':  'Your monitor picked up a new sound.',
  },
  {
    'title': 'Sound continues \u{1F50A}',
    'body':  'Sound has been ongoing for a while.',
  },
  {
    'title': 'Possible cry detected \u{1F476}',
    'body':  'Your monitor detected what might be crying.',
  },
  {
    'title': 'Cry detected \u{1F476}',
    'body':  'Your monitor thinks your baby is crying.',
  },
  {
    'title': 'Your baby is crying! \u{1F476}',
    'body':  'Your monitor is confident your baby needs attention.',
  },
  {
    'title': 'Possible crying continues \u{1F476}',
    'body':  'Possible crying has continued for a while.',
  },
  {
    'title': 'Crying continues \u{1F476}',
    'body':  'Your baby has been crying for a while.',
  },
  {
    'title': 'Baby still crying \u{1F476}',
    'body':  'Your baby has been crying — please check in.',
  },
  {
    'title': 'Cry detected (legacy) \u{1F476}',
    'body':  'Your baby monitor detected crying.',
  },
  {
    'title': 'Monitor is ready! \u{1F389}',
    'body':  'Setup complete. You can now use your baby monitor.',
  },
  {
    'title': 'Monitor update available',
    'body':  'A new update is available for your monitor.',
  },
  {
    'title': 'Monitor updated \u{2713}',
    'body':  'Your monitor has been successfully updated.',
  },
  {
    'title': 'Low battery \u26A0\uFE0F',
    'body':  'Your monitor\'s battery is running low. Please charge it soon.',
  },
];

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              color: _ter, fontSize: 11, fontWeight: FontWeight.w600,
              letterSpacing: 0.8)),
    );
  }
}

class _MonitorVariantRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool active;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  const _MonitorVariantRow({
    required this.label, required this.subtitle, required this.active,
    required this.onStart, required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: active ? _green : _grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              Text(subtitle, style: const TextStyle(color: _ter, fontSize: 12)),
            ],
          ),
        ),
        if (!active)
          _PillButton(label: 'Start', primary: true, onTap: onStart)
        else
          _PillButton(label: 'End', primary: false, onTap: onEnd),
      ],
    );
  }
}

class _AudioSimButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _AudioSimButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? _green.withValues(alpha: 0.18) : _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _green.withValues(alpha: 0.5) : _grey,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.graphic_eq : Icons.mic_none,
              size: 13,
              color: active ? _green : _ter,
            ),
            const SizedBox(width: 5),
            Text(
              active ? 'Simulating' : 'Simulate',
              style: TextStyle(
                color: active ? _green : _ter,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool active;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  const _ActivityRow({
    required this.label, required this.subtitle, required this.active,
    required this.onStart, required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: active ? _green : _grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              Text(subtitle, style: const TextStyle(color: _ter, fontSize: 12)),
            ],
          ),
        ),
        if (!active)
          _PillButton(label: 'Start', primary: true, onTap: onStart)
        else
          _PillButton(label: 'End', primary: false, onTap: onEnd),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: primary ? _clay : _card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: primary ? const Color(0xFF0F0D0B) : _sec,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EndAllButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EndAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _red.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: const Text('End All Activities',
            style: TextStyle(color: _red, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _SliderRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label, style: const TextStyle(color: _sec, fontSize: 13))),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _clay,
              inactiveTrackColor: _card,
              thumbColor: _clay,
              overlayColor: _clay.withValues(alpha: 0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(value * 100).round()}%',
            style: const TextStyle(color: _ter, fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _CycleRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCycle;
  const _CycleRow({required this.label, required this.value, required this.onCycle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label, style: const TextStyle(color: _sec, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13))),
        GestureDetector(
          onTap: onCycle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(8)),
            child: const Text('Cycle', style: TextStyle(color: _sec, fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _StepRow({required this.label, required this.value, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label, style: const TextStyle(color: _sec, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13))),
        GestureDetector(
          onTap: onMinus,
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: const Text('−', style: TextStyle(color: _sec, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onPlus,
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: const Text('+', style: TextStyle(color: _sec, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onToggle;
  const _ToggleRow({required this.label, required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label, style: const TextStyle(color: _sec, fontSize: 13))),
        Expanded(
          child: Text(active ? 'Running' : 'Off',
              style: TextStyle(color: active ? _clay : _ter, fontSize: 13)),
        ),
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 44, height: 26,
            decoration: BoxDecoration(
              color: active ? _clay : _grey,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: active ? Alignment.centerRight : Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Feed URL row ────────────────────────────────────────────────────────────


class _NotificationRow extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onFire;
  const _NotificationRow({required this.title, required this.body, required this.onFire});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              Text(body,  style: const TextStyle(color: _ter, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onFire,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(8)),
            child: const Text('Fire', style: TextStyle(color: _clay, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _AutoLoopButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _AutoLoopButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? _clay.withValues(alpha: 0.15) : _card,
          borderRadius: BorderRadius.circular(12),
          border: active ? Border.all(color: _clay.withValues(alpha: 0.4)) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          active ? 'Auto-Loop ON — updating every 3s' : 'Auto-Loop OFF',
          style: TextStyle(
            color: active ? _clay : _ter,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
