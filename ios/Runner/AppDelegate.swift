import ActivityKit
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  // ── Live Activity ──────────────────────────────────────────────────────────
  private var activity: Activity<MoonboonActivityAttributes>?
  private var activeVariant: Int?
  private var startTime: Date?

  // ── Call events → Flutter ──────────────────────────────────────────────────
  private var callEventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Reconcile any live activity left from a previous session
    if #available(iOS 16.2, *) {
      if let existing = Activity<MoonboonActivityAttributes>.activities.first {
        activity = existing
        activeVariant = existing.attributes.designVariant
        startTime = Date()
      }
    }

    // Wire cry call state → Flutter event channel
    CryCallService.shared.onStateChanged = { [weak self] state in
      self?.callEventSink?(state)
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // ── Native video platform view ─────────────────────────────────────────
    if let videoRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativeVideoPlayer") {
      videoRegistrar.register(
        NativeVideoPlayerFactory(messenger: videoRegistrar.messenger()),
        withId: "com.moonboon/native_video_player"
      )
    }

    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LiveActivity") else { return }

    // ── Method channel (Live Activity + Cry Call) ──────────────────────────
    let channel = FlutterMethodChannel(
      name: "com.moonboon/live_activity",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      switch call.method {
      case "start":              self.handleStart(call.arguments, result: result)
      case "update":             self.handleUpdate(call.arguments, result: result)
      case "end":                self.handleEnd(call.arguments, result: result)
      case "endAll":             self.handleEndAll(result: result)
      case "getActiveVariant":   self.handleGetActiveVariant(result: result)
      // Cry call
      case "reportCry":          self.handleReportCry(call.arguments, result: result)
      case "endCryCall":         self.handleEndCryCall(result: result)
      case "soundLevelUpdate":   self.handleSoundLevelUpdate(call.arguments, result: result)
      case "getCallState":       result(CryCallService.shared.callState)
      case "getQuietRemaining":  result(CryCallService.shared.quietTimerRemaining)
      default:                   result(FlutterMethodNotImplemented)
      }
    }

    // ── Event channel (call state push → Flutter) ──────────────────────────
    let eventChannel = FlutterEventChannel(
      name: "com.moonboon/call_events",
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(self)
  }

  // MARK: - Cry Call Handlers

  private func handleReportCry(_ arguments: Any?, result: @escaping FlutterResult) {
    let babyName = (arguments as? [String: Any])?["babyName"] as? String ?? "Baby"
    CryCallService.shared.reportIncomingCry(babyName: babyName)
    result(nil)
  }

  private func handleEndCryCall(result: @escaping FlutterResult) {
    CryCallService.shared.endCall()
    result(nil)
  }

  private func handleSoundLevelUpdate(_ arguments: Any?, result: @escaping FlutterResult) {
    let level = (arguments as? [String: Any])?["level"] as? Double ?? 0.0
    CryCallService.shared.soundLevelUpdated(level)
    result(nil)
  }

  // MARK: - Live Activity Handlers

  private func handleGetActiveVariant(result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else { result(nil); return }
    if let existing = Activity<MoonboonActivityAttributes>.activities.first {
      result(existing.attributes.designVariant)
    } else {
      result(nil)
    }
  }

  private func handleStart(_ arguments: Any?, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *),
          let args        = arguments as? [String: Any],
          let variant     = args["variant"]      as? Int,
          let babyName    = args["babyName"]     as? String,
          let soundLevel  = args["soundLevel"]   as? Double,
          let statusLabel = args["statusLabel"]  as? String,
          let battery     = args["battery"]      as? Int,
          let charging    = args["charging"]     as? Bool,
          let connection  = args["connection"]   as? String,
          let wifi        = args["wifi"]         as? Double
    else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
      return
    }

    let temperature    = args["temp"]         as? Int
    let motorRunning   = args["motorRunning"] as? Bool   ?? false
    let motorProgram   = args["motorProgram"] as? String ?? ""
    let monitorOn      = args["monitorOn"]    as? Bool   ?? true
    let monitorMode    = args["monitorMode"]  as? String ?? "Standard"
    let humidity       = args["humidity"]     as? Int
    let napSeconds     = args["napSeconds"]   as? Int

    let attrs = MoonboonActivityAttributes(babyName: babyName, designVariant: variant)
    let state = MoonboonActivityAttributes.ContentState(
      soundLevel: soundLevel, isMicMuted: false, temperature: temperature,
      batteryLevel: battery, isCharging: charging, statusLabel: statusLabel,
      connectionState: connection, wifiStrength: wifi, elapsedSeconds: 0,
      motorRunning: motorRunning, motorProgram: motorProgram,
      monitorOn: monitorOn, monitorMode: monitorMode,
      humidity: humidity, napSeconds: napSeconds
    )

    Task {
      if let current = self.activity { await current.end(nil, dismissalPolicy: .immediate) }
      for a in Activity<MoonboonActivityAttributes>.activities { await a.end(nil, dismissalPolicy: .immediate) }
      self.activity = nil
      self.activeVariant = nil

      do {
        let newActivity = try Activity<MoonboonActivityAttributes>.request(
          attributes: attrs,
          content: ActivityContent(state: state, staleDate: nil),
          pushType: nil
        )
        self.activity = newActivity
        self.activeVariant = variant
        self.startTime = Date()
        result(variant)
      } catch {
        result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func handleUpdate(_ arguments: Any?, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *),
          let args        = arguments as? [String: Any],
          let soundLevel  = args["soundLevel"]  as? Double,
          let statusLabel = args["statusLabel"] as? String,
          let battery     = args["battery"]     as? Int,
          let charging    = args["charging"]    as? Bool,
          let connection  = args["connection"]  as? String,
          let wifi        = args["wifi"]        as? Double
    else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
      return
    }

    guard let current = activity else { result(nil); return }
    let temperature  = args["temp"]         as? Int
    let motorRunning = args["motorRunning"] as? Bool   ?? false
    let motorProgram = args["motorProgram"] as? String ?? ""
    let monitorOn    = args["monitorOn"]    as? Bool   ?? true
    let monitorMode  = args["monitorMode"]  as? String ?? "Standard"
    let humidity     = args["humidity"]     as? Int
    let napSeconds   = args["napSeconds"]   as? Int
    Task {
      let elapsed = args["elapsedSeconds"] as? Int ?? Int(Date().timeIntervalSince(self.startTime ?? Date()))
      let state = MoonboonActivityAttributes.ContentState(
        soundLevel: soundLevel, isMicMuted: false, temperature: temperature,
        batteryLevel: battery, isCharging: charging, statusLabel: statusLabel,
        connectionState: connection, wifiStrength: wifi, elapsedSeconds: elapsed,
        motorRunning: motorRunning, motorProgram: motorProgram,
        monitorOn: monitorOn, monitorMode: monitorMode,
        humidity: humidity, napSeconds: napSeconds
      )
      await current.update(ActivityContent(state: state, staleDate: nil))
      result(nil)
    }
  }

  private func handleEnd(_ arguments: Any?, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *),
          let args    = arguments as? [String: Any],
          let variant = args["variant"] as? Int
    else { result(nil); return }

    guard variant == activeVariant, let current = activity else { result(nil); return }
    Task {
      await current.end(nil, dismissalPolicy: .immediate)
      self.activity = nil
      self.activeVariant = nil
      self.startTime = nil
      result(nil)
    }
  }

  private func handleEndAll(result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else { result(nil); return }
    Task {
      if let current = self.activity { await current.end(nil, dismissalPolicy: .immediate) }
      for a in Activity<MoonboonActivityAttributes>.activities { await a.end(nil, dismissalPolicy: .immediate) }
      self.activity = nil
      self.activeVariant = nil
      self.startTime = nil
      result(nil)
    }
  }
}

// MARK: - FlutterStreamHandler (call events)

extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    callEventSink = events
    // Send current state immediately
    events(CryCallService.shared.callState)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    callEventSink = nil
    return nil
  }
}
