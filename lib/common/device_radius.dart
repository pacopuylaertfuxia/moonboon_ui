import 'package:screen_corner_radius/screen_corner_radius.dart';

/// Mirrors production DeviceRadius — call init() once at app start.
class DeviceRadius {
  static DeviceRadius? _instance;
  static DeviceRadius get instance => _instance ??= DeviceRadius._();
  DeviceRadius._();

  ScreenRadius? screenRadius;

  Future<void> init() async {
    try {
      screenRadius = await ScreenCornerRadius.get();
    } catch (_) {
      // Not supported on web
    }
  }

  /// Bottom sheet inner radius = device screen corner radius - 4.
  /// Falls back to 0 (flat) when corner radius is unavailable (older devices).
  double get bottomSheetRadius =>
      (screenRadius?.bottomLeft ?? 0.0) > 0
          ? (screenRadius!.bottomLeft) - 4
          : 0.0;
}
