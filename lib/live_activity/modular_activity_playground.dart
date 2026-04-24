import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Palette — matches the dark widget
const _bg      = Color(0xFF0F0D0B);
const _surface = Color(0xFF1E1A16);
const _card    = Color(0xFF2E2820);
const _pri     = Color(0xFFF5F3F1);
const _sec     = Color(0xFFC4AA8E);
const _ter     = Color(0xFF8C8178);
const _clay    = Color(0xFFB59E85);
const _green   = Color(0xFF34C759);
const _red     = Color(0xFFFF3B30);
const _grey    = Color(0xFF3D352C);

const _channel = MethodChannel('com.moonboon/live_activity');

class ModularActivityPlayground extends StatefulWidget {
  const ModularActivityPlayground({super.key});
  @override
  State<ModularActivityPlayground> createState() => _ModularActivityPlaygroundState();
}

class _ModularActivityPlaygroundState extends State<ModularActivityPlayground> {
  // ── State ────────────────────────────────────────────────────────────────
  double  _soundLevel   = 0.0;
  bool    _motorRunning = false;
  String  _motorProgram = 'Medium';
  bool    _monitorOn    = true;
  String  _monitorMode  = 'Standard';
  int     _battery      = 82;
  bool    _charging     = false;
  int     _temp         = 20;
  int     _humidity     = 55;
  String  _connection   = 'connected';
  double  _wifi         = 0.9;
  bool    _isActive     = false;
  String? _error;

  // Elapsed + nap timers
  int     _elapsed      = 0;
  int?    _napSeconds;
  Timer?  _elapsedTimer;
  Timer?  _napTimer;

  static const _motors  = ['Quick', 'Medium', 'Long'];
  static const _modes   = ['Quiet', 'Standard', 'Maximum'];

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _napTimer?.cancel();
    if (_isActive) _end();
    super.dispose();
  }

  // ── Native bridge ────────────────────────────────────────────────────────

  Future<void> _start() async {
    try {
      await _channel.invokeMethod('start', {
        'variant':      7,
        'babyName':     'Baby',
        'soundLevel':   _soundLevel,
        'statusLabel':  _statusLabel,
        'battery':      _battery,
        'charging':     _charging,
        'connection':   _connection,
        'wifi':         _wifi,
        'temp':         _temp,
        'motorRunning': _motorRunning,
        'motorProgram': _motorProgram,
        'monitorOn':    _monitorOn,
        'monitorMode':  _monitorMode,
        'humidity':     _humidity,
        'napSeconds':   _napSeconds,
        'elapsedSeconds': _elapsed,
      });
      setState(() { _isActive = true; _error = null; });
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed++);
        _update();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _update() async {
    if (!_isActive) return;
    try {
      await _channel.invokeMethod('update', {
        'soundLevel':   _soundLevel,
        'statusLabel':  _statusLabel,
        'battery':      _battery,
        'charging':     _charging,
        'connection':   _connection,
        'wifi':         _wifi,
        'temp':         _temp,
        'motorRunning': _motorRunning,
        'motorProgram': _motorProgram,
        'monitorOn':    _monitorOn,
        'monitorMode':  _monitorMode,
        'humidity':     _humidity,
        'napSeconds':   _napSeconds,
        'elapsedSeconds': _elapsed,
      });
    } catch (_) {}
  }

  Future<void> _end() async {
    _elapsedTimer?.cancel();
    _napTimer?.cancel();
    try {
      await _channel.invokeMethod('end', {'variant': 7});
    } catch (_) {}
    setState(() { _isActive = false; _elapsed = 0; _napSeconds = null; });
  }

  String get _statusLabel {
    if (_soundLevel > 0.15) return 'Crying';
    if (_napSeconds != null) return 'Sleeping';
    return 'Quiet';
  }

  void _setSoundLevel(double v) {
    setState(() => _soundLevel = v);
    // Start nap timer when quiet
    if (v <= 0.15 && _napTimer == null) {
      _napSeconds = 0;
      _napTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _napSeconds = (_napSeconds ?? 0) + 1);
      });
    } else if (v > 0.15) {
      _napTimer?.cancel();
      _napTimer = null;
      setState(() => _napSeconds = null);
    }
    _update();
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final isCrying = _soundLevel > 0.15;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // ── Header ─────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 16),
          color: _surface,
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.arrow_back_ios_new, color: _pri, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Modular Activity', style: TextStyle(color: _pri, fontSize: 16, fontWeight: FontWeight.w700)),
              Text(_isActive ? 'Live on lock screen' : 'Not active', style: TextStyle(color: _isActive ? _green : _ter, fontSize: 12)),
            ]),
            const Spacer(),
            GestureDetector(
              onTap: _isActive ? _end : _start,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isActive ? _red.withValues(alpha: 0.15) : _green.withValues(alpha: 0.15),
                  border: Border.all(color: _isActive ? _red : _green),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isActive ? 'End' : 'Start',
                  style: TextStyle(color: _isActive ? _red : _green, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ]),
        ),

        // ── Preview card (what the lock screen widget looks like) ───────
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF0F0D0B), borderRadius: BorderRadius.circular(16)),
          child: _WidgetPreview(
            soundLevel: _soundLevel,
            motorRunning: _motorRunning,
            motorProgram: _motorProgram,
            monitorOn: _monitorOn,
            monitorMode: _monitorMode,
            battery: _battery,
            charging: _charging,
            temp: _temp,
            humidity: _humidity,
            connection: _connection,
            wifi: _wifi,
            elapsed: _elapsed,
            napSeconds: _napSeconds,
          ),
        ),

        // ── Controls ────────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [

              // Sound
              _label('Sound level'),
              _row(children: [
                Expanded(child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: isCrying ? _red : _green,
                    inactiveTrackColor: _grey,
                    thumbColor: isCrying ? _red : _green,
                    overlayColor: (isCrying ? _red : _green).withValues(alpha: 0.15),
                    trackHeight: 4,
                  ),
                  child: Slider(value: _soundLevel, onChanged: _setSoundLevel),
                )),
                SizedBox(width: 40, child: Text('${(_soundLevel * 100).toInt()}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12, color: isCrying ? _red : _green))),
              ]),
              Text(isCrying ? 'Sound detected — EQ bars visible' : _napSeconds != null
                  ? 'Quiet · nap ${_napFmt(_napSeconds)}' : 'Quiet',
                  style: const TextStyle(fontSize: 11, color: _ter)),

              const SizedBox(height: 20),

              // Motor
              _label('Motor / Bouncer'),
              _toggleRow('Motor running', _motorRunning, (v) {
                setState(() => _motorRunning = v);
                _update();
              }),
              if (_motorRunning) ...[
                const SizedBox(height: 8),
                _segmented(_motors, _motorProgram, (v) { setState(() => _motorProgram = v); _update(); }),
              ],

              const SizedBox(height: 20),

              // Monitor
              _label('Monitor'),
              _toggleRow('Monitor on', _monitorOn, (v) {
                setState(() => _monitorOn = v);
                _update();
              }),
              if (_monitorOn) ...[
                const SizedBox(height: 8),
                _segmented(_modes, _monitorMode, (v) { setState(() => _monitorMode = v); _update(); }),
              ],

              const SizedBox(height: 20),

              // Environment
              _label('Environment'),
              _intSlider('Temperature', _temp, 10, 35, '°C', (v) { setState(() => _temp = v); _update(); }),
              const SizedBox(height: 8),
              _intSlider('Humidity', _humidity, 20, 90, '%', (v) { setState(() => _humidity = v); _update(); }),

              const SizedBox(height: 20),

              // Device
              _label('Device'),
              _intSlider('Battery', _battery, 0, 100, '%', (v) { setState(() => _battery = v); _update(); }),
              const SizedBox(height: 8),
              _toggleRow('Charging', _charging, (v) { setState(() => _charging = v); _update(); }),
              const SizedBox(height: 8),
              _toggleRow('Connected', _connection == 'connected', (v) {
                setState(() => _connection = v ? 'connected' : 'disconnected');
                _update();
              }),
              const SizedBox(height: 8),
              _intSlider('WiFi strength', (_wifi * 100).toInt(), 0, 100, '%', (v) {
                setState(() => _wifi = v / 100);
                _update();
              }),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: const TextStyle(color: _red, fontSize: 11)),
                ),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _napFmt(int? s) {
    if (s == null || s == 0) return '';
    if (s < 60) return '${s}s';
    if (s < 3600) return '${s ~/ 60}m';
    return '${s ~/ 3600}h ${(s % 3600) ~/ 60}m';
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: _ter)),
  );

  Widget _row({required List<Widget> children}) => Row(children: children);

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) => Row(children: [
    Text(label, style: const TextStyle(fontSize: 13, color: _sec)),
    const Spacer(),
    Transform.scale(
      scale: 0.8,
      child: Switch(value: value, onChanged: onChanged, activeColor: _clay),
    ),
  ]);

  Widget _intSlider(String label, int value, int min, int max, String unit, ValueChanged<int> onChanged) => Row(children: [
    SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, color: _sec))),
    Expanded(child: SliderTheme(
      data: SliderThemeData(activeTrackColor: _clay, inactiveTrackColor: _grey, thumbColor: _clay, trackHeight: 3),
      child: Slider(value: value.toDouble(), min: min.toDouble(), max: max.toDouble(),
          onChanged: (v) => onChanged(v.toInt())),
    )),
    SizedBox(width: 44, child: Text('$value$unit', textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 12, color: _clay))),
  ]);

  Widget _segmented(List<String> options, String selected, ValueChanged<String> onChanged) => Row(
    children: options.map((o) {
      final active = o == selected;
      return GestureDetector(
        onTap: () => onChanged(o),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? _clay : _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? _clay : _grey, width: active ? 0 : 1),
          ),
          child: Text(o, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: active ? Colors.black87 : _sec)),
        ),
      );
    }).toList(),
  );
}

// ── In-app preview of the lock screen widget ──────────────────────────────────

class _WidgetPreview extends StatelessWidget {
  final double soundLevel;
  final bool motorRunning;
  final String motorProgram;
  final bool monitorOn;
  final String monitorMode;
  final int battery;
  final bool charging;
  final int temp;
  final int humidity;
  final String connection;
  final double wifi;
  final int elapsed;
  final int? napSeconds;

  const _WidgetPreview({
    required this.soundLevel, required this.motorRunning, required this.motorProgram,
    required this.monitorOn, required this.monitorMode, required this.battery,
    required this.charging, required this.temp, required this.humidity,
    required this.connection, required this.wifi, required this.elapsed,
    required this.napSeconds,
  });

  bool get isCrying => soundLevel > 0.15;

  Color get statusColor => isCrying ? _red : _green;

  String get napLabel {
    final s = napSeconds;
    if (s == null || s == 0) return 'Quiet';
    if (s < 60) return 'Quiet ${s}s';
    if (s < 3600) return 'Quiet ${s ~/ 60}m';
    return 'Quiet ${s ~/ 3600}h ${(s % 3600) ~/ 60}m';
  }

  String get elapsedLabel {
    if (elapsed < 60) return '${elapsed}s';
    if (elapsed < 3600) return '${elapsed ~/ 60}m';
    return '${elapsed ~/ 3600}h ${(elapsed % 3600) ~/ 60}m';
  }

  IconData get batteryIcon {
    if (charging) return Icons.battery_charging_full;
    if (battery > 75) return Icons.battery_full;
    if (battery > 50) return Icons.battery_5_bar;
    if (battery > 25) return Icons.battery_3_bar;
    return Icons.battery_1_bar;
  }

  Color get batteryColor {
    if (charging) return _green;
    if (battery > 25) return _ter;
    return _red;
  }

  IconData get wifiIcon {
    if (wifi < 0.33) return Icons.wifi_off;
    if (wifi < 0.66) return Icons.network_wifi_1_bar;
    return Icons.wifi;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Row 1: status
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        child: Row(children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('Baby', style: TextStyle(color: _pri, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(isCrying ? 'Sound detected' : napLabel, style: const TextStyle(color: _sec, fontSize: 12)),
          const Spacer(),
          Text(elapsedLabel, style: const TextStyle(color: _ter, fontSize: 11, fontFeatures: [FontFeature.tabularFigures()])),
        ]),
      ),

      // Row 2: sound bars + temp + humidity
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 7, 14, 0),
        child: Row(children: [
          if (isCrying) ...[
            _MiniEQ(level: soundLevel),
            const SizedBox(width: 8),
          ],
          const Spacer(),
          _Chip(icon: Icons.thermostat, label: '$temp°C'),
          const SizedBox(width: 6),
          _Chip(icon: Icons.water_drop_outlined, label: '$humidity%'),
        ]),
      ),

      // Divider
      Container(height: 0.5, margin: const EdgeInsets.fromLTRB(14, 8, 14, 0), color: Colors.white12),

      // Row 3: motor · monitor · battery · wifi
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        child: Row(children: [
          _Chip(
            icon: Icons.rotate_right,
            label: motorRunning ? 'Motor · $motorProgram' : 'Motor off',
            color: motorRunning ? _clay : _ter,
          ),
          const SizedBox(width: 6),
          _Chip(
            icon: monitorOn ? Icons.mic : Icons.mic_off,
            label: monitorOn ? monitorMode : 'Monitor off',
            color: monitorOn ? _green : _ter,
          ),
          const Spacer(),
          Icon(batteryIcon, size: 14, color: batteryColor),
          const SizedBox(width: 2),
          Text('$battery%', style: const TextStyle(color: _ter, fontSize: 10)),
          const SizedBox(width: 6),
          Icon(wifiIcon, size: 13, color: connection == 'connected' ? _sec : _red),
        ]),
      ),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, this.color = _sec});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 9, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _sec)),
    ]),
  );
}

class _MiniEQ extends StatelessWidget {
  final double level;
  const _MiniEQ({required this.level});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final wave = i % 3 == 0 ? 1.0 : i % 3 == 1 ? 0.55 : 0.3;
          final h = (3 + wave * level * 13).clamp(2.0, 16.0);
          return Container(
            width: 2, height: h,
            margin: const EdgeInsets.only(right: 1.5),
            decoration: BoxDecoration(
              color: Color.lerp(_clay, _red, level),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }
}
