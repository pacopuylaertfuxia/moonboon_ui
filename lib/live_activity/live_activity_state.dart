import 'package:equatable/equatable.dart';

class LiveActivityState extends Equatable {
  // ── Monitor ──────────────────────────────────────────────────────────────
  final bool monitorActive;   // Variant A
  final bool monitorActiveB;  // Variant B
  final double soundLevel;
  final String statusLabel;
  final int? temperature;
  final int monitorBattery;
  final bool monitorCharging;

  // ── Motor ────────────────────────────────────────────────────────────────
  final bool motorActive;
  final bool motorRunning;
  final String motorProgram;
  final int motorSpeed;
  final int? motorRemainingSeconds;
  final int motorBattery;
  final bool motorCharging;

  // ── UI ───────────────────────────────────────────────────────────────────
  final bool isAutoLooping;
  final bool isSimulatingAudio;
  final String? error;
  final int monitorVariant; // 1 = A, 2 = B

  const LiveActivityState({
    this.monitorActive = false,
    this.monitorActiveB = false,
    this.soundLevel = 0.05,
    this.statusLabel = 'Sleeping',
    this.temperature = 21,
    this.monitorBattery = 75,
    this.monitorCharging = false,
    this.motorActive = false,
    this.motorRunning = false,
    this.motorProgram = 'Gentle',
    this.motorSpeed = 5,
    this.motorRemainingSeconds,
    this.motorBattery = 80,
    this.motorCharging = false,
    this.isAutoLooping = false,
    this.isSimulatingAudio = false,
    this.error,
    this.monitorVariant = 1,
  });

  LiveActivityState copyWith({
    bool? monitorActive,
    bool? monitorActiveB,
    double? soundLevel,
    String? statusLabel,
    int? temperature,
    bool clearTemperature = false,
    int? monitorBattery,
    bool? monitorCharging,
    bool? motorActive,
    bool? motorRunning,
    String? motorProgram,
    int? motorSpeed,
    int? motorRemainingSeconds,
    bool clearMotorTimer = false,
    int? motorBattery,
    bool? motorCharging,
    bool? isAutoLooping,
    bool? isSimulatingAudio,
    String? error,
    bool clearError = false,
    int? monitorVariant,
  }) {
    return LiveActivityState(
      monitorActive:          monitorActive       ?? this.monitorActive,
      monitorActiveB:         monitorActiveB      ?? this.monitorActiveB,
      soundLevel:             soundLevel          ?? this.soundLevel,
      statusLabel:            statusLabel         ?? this.statusLabel,
      temperature:            clearTemperature ? null : (temperature ?? this.temperature),
      monitorBattery:         monitorBattery      ?? this.monitorBattery,
      monitorCharging:        monitorCharging     ?? this.monitorCharging,
      motorActive:            motorActive         ?? this.motorActive,
      motorRunning:           motorRunning        ?? this.motorRunning,
      motorProgram:           motorProgram        ?? this.motorProgram,
      motorSpeed:             motorSpeed          ?? this.motorSpeed,
      motorRemainingSeconds:  clearMotorTimer ? null : (motorRemainingSeconds ?? this.motorRemainingSeconds),
      motorBattery:           motorBattery        ?? this.motorBattery,
      motorCharging:          motorCharging       ?? this.motorCharging,
      isAutoLooping:          isAutoLooping       ?? this.isAutoLooping,
      isSimulatingAudio:      isSimulatingAudio   ?? this.isSimulatingAudio,
      error:                  clearError ? null : (error ?? this.error),
      monitorVariant:         monitorVariant      ?? this.monitorVariant,
    );
  }

  @override
  List<Object?> get props => [
    monitorActive, monitorActiveB, soundLevel, statusLabel, temperature,
    monitorBattery, monitorCharging,
    motorActive, motorRunning, motorProgram, motorSpeed,
    motorRemainingSeconds, motorBattery, motorCharging,
    isAutoLooping, isSimulatingAudio, error, monitorVariant,
  ];
}
