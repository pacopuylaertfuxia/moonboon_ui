import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Source ────────────────────────────────────────────────────────────────────

enum NapSource { manual, motor, monitor }

// ── Data ──────────────────────────────────────────────────────────────────────

class MockNap {
  final DateTime start;
  final DateTime end;
  final NapSource source;
  const MockNap({
    required this.start,
    required this.end,
    this.source = NapSource.manual,
  });
  Duration get duration => end.difference(start);
}

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _todayMidnight() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

// ── State ─────────────────────────────────────────────────────────────────────

class MockNapState {
  final DateTime selectedDate;
  final Map<String, List<MockNap>> napsByDate;
  final DateTime? activeNapStart;
  final NapSource activeNapSource;
  final DateTime now;
  final bool isMotorRunning;
  final bool isMonitorActive;
  // Key: date string (yyyy-MM-dd), value: list of photo bytes
  final Map<String, List<Uint8List>> photosByDate;

  const MockNapState({
    required this.selectedDate,
    required this.napsByDate,
    required this.activeNapStart,
    required this.now,
    this.activeNapSource = NapSource.manual,
    this.isMotorRunning = false,
    this.isMonitorActive = false,
    this.photosByDate = const {},
  });

  List<MockNap> get napsForDate => napsByDate[_dateKey(selectedDate)] ?? const [];
  List<Uint8List> get photosForDate => photosByDate[_dateKey(selectedDate)] ?? const [];
  bool get isAtToday => selectedDate == _todayMidnight();
  Duration get activeNapDuration =>
      activeNapStart == null ? Duration.zero : now.difference(activeNapStart!);

  MockNapState copyWith({
    DateTime? selectedDate,
    Map<String, List<MockNap>>? napsByDate,
    DateTime? activeNapStart,
    bool clearActiveNap = false,
    NapSource? activeNapSource,
    DateTime? now,
    bool? isMotorRunning,
    bool? isMonitorActive,
    Map<String, List<Uint8List>>? photosByDate,
  }) =>
      MockNapState(
        selectedDate: selectedDate ?? this.selectedDate,
        napsByDate: napsByDate ?? this.napsByDate,
        activeNapStart: clearActiveNap ? null : (activeNapStart ?? this.activeNapStart),
        activeNapSource: activeNapSource ?? this.activeNapSource,
        now: now ?? this.now,
        isMotorRunning: isMotorRunning ?? this.isMotorRunning,
        isMonitorActive: isMonitorActive ?? this.isMonitorActive,
        photosByDate: photosByDate ?? this.photosByDate,
      );

  MockNapState withStoppedNap(MockNap nap) {
    final key = _dateKey(selectedDate);
    final updated = Map<String, List<MockNap>>.from(napsByDate);
    updated[key] = [...(updated[key] ?? const []), nap];
    return copyWith(napsByDate: updated, clearActiveNap: true, now: DateTime.now());
  }
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class MockNapCubit extends Cubit<MockNapState> {
  Timer? _ticker;

  MockNapCubit() : super(_initialState());

  static MockNapState _initialState() {
    final today = _todayMidnight();
    final d1 = today.subtract(const Duration(days: 1));
    final d2 = today.subtract(const Duration(days: 2));

    return MockNapState(
      selectedDate: today,
      activeNapStart: null,
      now: DateTime.now(),
      isMotorRunning: true,   // mock: motor is on so we see the device context UI
      isMonitorActive: true,  // mock: monitor is streaming
      napsByDate: {
        _dateKey(today): [
          MockNap(
            start: today.add(const Duration(hours: 9, minutes: 30)),
            end: today.add(const Duration(hours: 10, minutes: 45)),
            source: NapSource.motor,
          ),
        ],
        _dateKey(d1): [
          MockNap(
            start: d1.add(const Duration(hours: 7, minutes: 55)),
            end: d1.add(const Duration(hours: 9, minutes: 10)),
            source: NapSource.manual,
          ),
          MockNap(
            start: d1.add(const Duration(hours: 13, minutes: 20)),
            end: d1.add(const Duration(hours: 14, minutes: 55)),
            source: NapSource.monitor,
          ),
        ],
        _dateKey(d2): [
          MockNap(
            start: d2.add(const Duration(hours: 8, minutes: 30)),
            end: d2.add(const Duration(hours: 9, minutes: 25)),
            source: NapSource.motor,
          ),
          MockNap(
            start: d2.add(const Duration(hours: 13, minutes: 0)),
            end: d2.add(const Duration(hours: 14, minutes: 30)),
            source: NapSource.manual,
          ),
          MockNap(
            start: d2.add(const Duration(hours: 17, minutes: 10)),
            end: d2.add(const Duration(hours: 17, minutes: 55)),
            source: NapSource.monitor,
          ),
        ],
      },
    );
  }

  void goToPreviousDay() =>
      emit(state.copyWith(selectedDate: state.selectedDate.subtract(const Duration(days: 1))));

  void goToNextDay() {
    if (state.isAtToday) return;
    emit(state.copyWith(selectedDate: state.selectedDate.add(const Duration(days: 1))));
  }

  void startNap({NapSource source = NapSource.manual}) {
    if (state.activeNapStart != null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) emit(state.copyWith(now: DateTime.now()));
    });
    emit(state.copyWith(
      activeNapStart: DateTime.now(),
      activeNapSource: source,
      now: DateTime.now(),
    ));
  }

  void stopNap() {
    _ticker?.cancel();
    _ticker = null;
    final start = state.activeNapStart;
    if (start == null) return;
    emit(state.withStoppedNap(MockNap(
      start: start,
      end: DateTime.now(),
      source: state.activeNapSource,
    )));
  }

  void toggleMotor() =>
      emit(state.copyWith(isMotorRunning: !state.isMotorRunning));

  void toggleMonitor() =>
      emit(state.copyWith(isMonitorActive: !state.isMonitorActive));

  void addPhoto(Uint8List bytes) {
    final key = _dateKey(state.selectedDate);
    final updated = Map<String, List<Uint8List>>.from(state.photosByDate);
    updated[key] = [...(updated[key] ?? const []), bytes];
    emit(state.copyWith(photosByDate: updated));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
