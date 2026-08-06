import ActivityKit
import AVFoundation
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  // ── Monitor Live Activity ──────────────────────────────────────────────────
  private var monitorActivity:  Activity<MoonboonActivityAttributes>?  // Variant A
  private var monitorActivityB: Activity<MoonboonActivityAttributes>?  // Variant B
  private var monitorStartTime:  Date?
  private var monitorStartTimeB: Date?

  // ── Motor Live Activity ────────────────────────────────────────────────────
  private var motorActivity: Activity<MotorActivityAttributes>?

  // ── Event sink (sound level push → Flutter) ───────────────────────────────
  private var callEventSink: FlutterEventSink?

  // ── Background keep-alive (silent loop → keeps Dart timers running) ─────────
  private var keepAliveEngine: AVAudioEngine?
  private var keepAlivePlayer: AVAudioPlayerNode?

  // ── Cry sound playback ────────────────────────────────────────────────────
  private var cryPlayer: AVAudioPlayer?


  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Request notification permission for cry alerts
    // Disabled on prototype branch — the permission dialog blocks screenshot runs.
    // UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

    // Reconnect any activities still running from a previous session
    if #available(iOS 16.2, *) {
      let monitors = Activity<MoonboonActivityAttributes>.activities
      monitorActivity  = monitors.first(where: { $0.attributes.designVariant == 1 }) ?? monitors.first
      monitorActivityB = monitors.first(where: { $0.attributes.designVariant == 2 })
      if monitorActivity  != nil { monitorStartTime  = Date() }
      if monitorActivityB != nil { monitorStartTimeB = Date() }
      motorActivity = Activity<MotorActivityAttributes>.activities.first
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LiveActivity") else { return }

    // ── Method channel ─────────────────────────────────────────────────────
    let channel = FlutterMethodChannel(
      name: "com.moonboon/live_activity",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      switch call.method {
      // Monitor
      case "startMonitor":    self.handleStartMonitor(call.arguments, result: result)
      case "updateMonitor":   self.handleUpdateMonitor(call.arguments, result: result)
      case "endMonitor":
        let v = (call.arguments as? [String: Any])?["variant"] as? Int ?? 0
        self.handleEndMonitor(variant: v, result: result)
      // Motor
      case "startMotor":      self.handleStartMotor(call.arguments, result: result)
      case "updateMotor":     self.handleUpdateMotor(call.arguments, result: result)
      case "endMotor":        self.handleEndMotor(result: result)
      // Shared
      case "endAll":          self.handleEndAll(result: result)
      case "getActiveVariant":
        if self.monitorActivity != nil && self.monitorActivityB != nil { result(3) }  // both
        else if self.monitorActivityB != nil { result(2) }
        else if self.monitorActivity  != nil { result(1) }
        else { result(nil) }
      // Cry notification (replaces CallKit)
      case "playCrySound":        self.playCrySound(); result(nil)
      case "stopCrySound":        self.stopCrySound(); result(nil)
      case "reportCry":           self.handleReportCry(call.arguments, result: result)
      case "fireNotification":    self.handleFireNotification(call.arguments, result: result)
      case "soundLevelUpdate":
        // Update monitor activity with new sound level if running
        if let args = call.arguments as? [String: Any],
           let level = args["level"] as? Double {
          self.updateMonitorSoundLevel(level)
        }
        result(nil)
      // Legacy aliases (keep playground working)
      case "start":           self.handleStartMonitor(call.arguments, result: result)
      case "update":          self.handleUpdateMonitor(call.arguments, result: result)
      case "end":             self.handleEndMonitor(result: result)
      default:                result(FlutterMethodNotImplemented)
      }
    }

    // ── Event channel (push state changes to Flutter) ─────────────────────
    let eventChannel = FlutterEventChannel(
      name: "com.moonboon/call_events",
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(self)
  }

  // MARK: - App Group image cache

  private let appGroupID = "group.com.moonboon.moonboonUi"
  private let frameFileName = "live_feed_frame.jpg"

  private func cacheFrameFromURL(_ urlString: String, completion: @escaping () -> Void) {
    guard let containerURL = FileManager.default
              .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    else { completion(); return }
    let destURL = containerURL.appendingPathComponent(frameFileName)

    // flutter_assets/ paths → load from the app bundle (works on device + simulator)
    if urlString.hasPrefix("flutter_assets/") {
      DispatchQueue.global(qos: .userInitiated).async {
        let fullPath = Bundle.main.bundlePath + "/" + urlString
        if let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) {
          try? data.write(to: destURL)
        }
        DispatchQueue.main.async { completion() }
      }
      return
    }

    guard let url = URL(string: urlString) else { completion(); return }

    if url.isFileURL {
      DispatchQueue.global(qos: .userInitiated).async {
        if let data = try? Data(contentsOf: url) {
          try? data.write(to: destURL)
        }
        DispatchQueue.main.async { completion() }
      }
    } else {
      URLSession.shared.dataTask(with: url) { data, _, _ in
        if let data = data { try? data.write(to: destURL) }
        completion()
      }.resume()
    }
  }

  private func clearCachedFrame() {
    guard let containerURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else { return }
    try? FileManager.default.removeItem(
      at: containerURL.appendingPathComponent(frameFileName))
  }

  // MARK: - Monitor Activity

  private func handleStartMonitor(_ arguments: Any?, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *),
          let args        = arguments as? [String: Any],
          let babyName    = args["babyName"]    as? String,
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

    let variant     = args["variant"]     as? Int ?? 1
    let temperature = args["temp"]        as? Int
    let imageUrl    = args["imageUrl"]    as? String

    let startActivity: (Bool) -> Void = { hasFeed in
      let attrs = MoonboonActivityAttributes(babyName: babyName, designVariant: variant)
      let state = MoonboonActivityAttributes.ContentState(
        soundLevel: soundLevel, isMicMuted: false, temperature: temperature,
        batteryLevel: battery, isCharging: charging, statusLabel: statusLabel,
        connectionState: connection, wifiStrength: wifi, elapsedSeconds: 0,
        hasCameraFeed: hasFeed
      )
      Task {
        // End existing activity for this variant slot only
        if variant == 2 {
          if let b = self.monitorActivityB { await b.end(nil, dismissalPolicy: .immediate) }
        } else {
          if let a = self.monitorActivity { await a.end(nil, dismissalPolicy: .immediate) }
        }
        do {
          let newActivity = try Activity<MoonboonActivityAttributes>.request(
            attributes: attrs,
            content: ActivityContent(state: state, staleDate: nil),
            pushType: nil
          )
          if variant == 2 {
            self.monitorActivityB = newActivity
            self.monitorStartTimeB = Date()
          } else {
            self.monitorActivity = newActivity
            self.monitorStartTime = Date()
          }
          result(variant)
        } catch {
          result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
        }
      }
    }

    startKeepAlive()    // keeps app alive in BG so Dart timers + image rotation keep firing

    if let url = imageUrl {
      cacheFrameFromURL(url) { startActivity(true) }
    } else {
      startActivity(false)
    }
  }

  private func handleUpdateMonitor(_ arguments: Any?, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *),
          let args        = arguments as? [String: Any],
          let soundLevel  = args["soundLevel"]  as? Double,
          let statusLabel = args["statusLabel"] as? String,
          let battery     = args["battery"]     as? Int,
          let charging    = args["charging"]    as? Bool,
          let connection  = args["connection"]  as? String,
          let wifi        = args["wifi"]        as? Double
    else { result(nil); return }

    guard monitorActivity != nil || monitorActivityB != nil else { result(nil); return }

    let temperature = args["temp"] as? Int
    let imageUrl    = args["imageUrl"] as? String
    let showAlert   = args["alert"] as? Bool ?? false
    let alertTitle  = args["alertTitle"]  as? String ?? "Baby Monitor"
    let alertBody   = args["alertBody"]   as? String ?? statusLabel

    let pushUpdate: (Bool) -> Void = { hasFeed in
      Task {
        // ── Variant A ──
        if let a = self.monitorActivity {
          let elapsed = Int(Date().timeIntervalSince(self.monitorStartTime ?? Date()))
          let state = MoonboonActivityAttributes.ContentState(
            soundLevel: soundLevel, isMicMuted: false, temperature: temperature,
            batteryLevel: battery, isCharging: charging, statusLabel: statusLabel,
            connectionState: connection, wifiStrength: wifi, elapsedSeconds: elapsed,
            hasCameraFeed: hasFeed
          )
          let content = ActivityContent(state: state, staleDate: nil)
          if showAlert {
            let alertConfig = AlertConfiguration(
              title: LocalizedStringResource(stringLiteral: alertTitle),
              body:  LocalizedStringResource(stringLiteral: alertBody),
              sound: .default
            )
            await a.update(content, alertConfiguration: alertConfig)
          } else {
            await a.update(content)
          }
        }
        // ── Variant B ──
        if let b = self.monitorActivityB {
          let elapsed = Int(Date().timeIntervalSince(self.monitorStartTimeB ?? Date()))
          let state = MoonboonActivityAttributes.ContentState(
            soundLevel: soundLevel, isMicMuted: false, temperature: temperature,
            batteryLevel: battery, isCharging: charging, statusLabel: statusLabel,
            connectionState: connection, wifiStrength: wifi, elapsedSeconds: elapsed,
            hasCameraFeed: hasFeed
          )
          await b.update(ActivityContent(state: state, staleDate: nil))
        }
        result(nil)
      }
    }

    // Stop audio when status leaves Crying
    if statusLabel != "Crying" {
      stopCrySound()
    }

    if let url = imageUrl {
      cacheFrameFromURL(url) { pushUpdate(true) }
    } else {
      let hasFeed: Bool = {
        guard let containerURL = FileManager.default
          .containerURL(forSecurityApplicationGroupIdentifier: self.appGroupID) else { return false }
        return FileManager.default.fileExists(
          atPath: containerURL.appendingPathComponent(self.frameFileName).path)
      }()
      pushUpdate(hasFeed)
    }
  }

  // MARK: - Background keep-alive (silent audio loop)

  private func startKeepAlive() {
    guard keepAliveEngine == nil else { return }
    let engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    engine.attach(player)
    engine.connect(player, to: engine.mainMixerNode, format: format)
    engine.mainMixerNode.outputVolume = 0  // silent — just keeps the session alive
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
      try AVAudioSession.sharedInstance().setActive(true)
      try engine.start()
      // Loop a tiny silent buffer — keeps the audio session active indefinitely
      if let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 4410) {
        buf.frameLength = 4410  // 0.1s of silence
        player.scheduleBuffer(buf, at: nil, options: .loops)
        player.play()
      }
      keepAliveEngine = engine
      keepAlivePlayer = player
    } catch {
      print("[Moonboon] Keep-alive audio error: \(error)")
    }
  }

  private func stopKeepAlive() {
    keepAlivePlayer?.stop()
    keepAliveEngine?.stop()
    keepAlivePlayer = nil
    keepAliveEngine = nil
    // Only deactivate if cry is not playing either
    if cryPlayer == nil {
      try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
  }


  // MARK: - Cry sound playback

  private func playCrySound() {
    guard cryPlayer == nil || !(cryPlayer!.isPlaying) else { return }

    // Flutter bundles assets at flutter_assets/<pubspec-path>, i.e. flutter_assets/assets/audio/
    let url: URL? = Bundle.main.url(forResource: "crying_baby", withExtension: "mp3",
                                     subdirectory: "flutter_assets/assets/audio")
                 ?? Bundle.main.url(forResource: "crying_baby", withExtension: "mp3",
                                     subdirectory: "flutter_assets/audio")
                 ?? Bundle.main.url(forResource: "crying_baby", withExtension: "mp3")

    guard let audioURL = url else {
      print("[Moonboon] crying_baby.mp3 not found — searched flutter_assets/assets/audio and bundle root")
      return
    }

    do {
      // Re-assert session in case anything reset it (e.g. was backgrounded briefly)
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
      try AVAudioSession.sharedInstance().setActive(true)
      cryPlayer = try AVAudioPlayer(contentsOf: audioURL)
      cryPlayer?.numberOfLoops = -1
      cryPlayer?.prepareToPlay()
      cryPlayer?.play()
      print("[Moonboon] Cry sound started: \(audioURL.lastPathComponent)")
    } catch {
      print("[Moonboon] AVAudioPlayer error: \(error)")
    }
  }

  private func stopCrySound() {
    cryPlayer?.stop()
    cryPlayer = nil
    // Don't deactivate session — keep-alive is still running
  }

  // variant: 1 = A only, 2 = B only, 0 = both
  private func handleEndMonitor(variant: Int = 0, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else { result(nil); return }
    Task {
      if variant == 0 || variant == 1, let a = self.monitorActivity {
        await a.end(nil, dismissalPolicy: .immediate)
        self.monitorActivity  = nil
        self.monitorStartTime = nil
      }
      if variant == 0 || variant == 2, let b = self.monitorActivityB {
        await b.end(nil, dismissalPolicy: .immediate)
        self.monitorActivityB  = nil
        self.monitorStartTimeB = nil
      }
      if self.monitorActivity == nil && self.monitorActivityB == nil {
        self.clearCachedFrame()
        self.stopCrySound()
        self.stopKeepAlive()
      }
      result(nil)
    }
  }

  private func updateMonitorSoundLevel(_ level: Double) {
    guard #available(iOS 16.2, *) else { return }
    Task {
      if let a = self.monitorActivity {
        var s = a.content.state; s.soundLevel = level
        await a.update(ActivityContent(state: s, staleDate: nil))
      }
      if let b = self.monitorActivityB {
        var s = b.content.state; s.soundLevel = level
        await b.update(ActivityContent(state: s, staleDate: nil))
      }
    }
  }

  // MARK: - Motor Activity

  private func handleStartMotor(_ arguments: Any?, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *),
          let args      = arguments as? [String: Any],
          let motorName = args["motorName"] as? String,
          let isRunning = args["isRunning"] as? Bool,
          let program   = args["program"]   as? String,
          let speed     = args["speed"]     as? Int,
          let battery   = args["battery"]   as? Int,
          let charging  = args["charging"]  as? Bool
    else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
      return
    }

    let remaining = args["remainingSeconds"] as? Int
    let attrs = MotorActivityAttributes(motorName: motorName)
    let state = MotorActivityAttributes.ContentState(
      isRunning: isRunning, program: program, speed: speed,
      remainingSeconds: remaining, batteryLevel: battery, isCharging: charging
    )

    Task {
      if let current = self.motorActivity { await current.end(nil, dismissalPolicy: .immediate) }
      for a in Activity<MotorActivityAttributes>.activities { await a.end(nil, dismissalPolicy: .immediate) }
      do {
        self.motorActivity = try Activity<MotorActivityAttributes>.request(
          attributes: attrs,
          content: ActivityContent(state: state, staleDate: nil),
          pushType: nil
        )
        result(nil)
      } catch {
        result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func handleUpdateMotor(_ arguments: Any?, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *),
          let args      = arguments as? [String: Any],
          let isRunning = args["isRunning"] as? Bool,
          let program   = args["program"]   as? String,
          let speed     = args["speed"]     as? Int,
          let battery   = args["battery"]   as? Int,
          let charging  = args["charging"]  as? Bool,
          let current   = motorActivity
    else { result(nil); return }

    let remaining = args["remainingSeconds"] as? Int
    Task {
      let state = MotorActivityAttributes.ContentState(
        isRunning: isRunning, program: program, speed: speed,
        remainingSeconds: remaining, batteryLevel: battery, isCharging: charging
      )
      await current.update(ActivityContent(state: state, staleDate: nil))
      result(nil)
    }
  }

  private func handleEndMotor(result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *), let current = motorActivity else { result(nil); return }
    Task {
      await current.end(nil, dismissalPolicy: .immediate)
      self.motorActivity = nil
      result(nil)
    }
  }

  // MARK: - Shared

  private func handleEndAll(result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else { result(nil); return }
    Task {
      for a in Activity<MoonboonActivityAttributes>.activities { await a.end(nil, dismissalPolicy: .immediate) }
      for a in Activity<MotorActivityAttributes>.activities     { await a.end(nil, dismissalPolicy: .immediate) }
      self.monitorActivity   = nil
      self.monitorActivityB  = nil
      self.motorActivity     = nil
      self.monitorStartTime  = nil
      self.monitorStartTimeB = nil
      self.clearCachedFrame()
      self.stopCrySound()
      self.stopKeepAlive()
      result(nil)
    }
  }

  // MARK: - Generic demo notification

  private func handleFireNotification(_ arguments: Any?, result: @escaping FlutterResult) {
    let args = arguments as? [String: Any]
    let title = args?["title"] as? String ?? "Notification"
    let body  = args?["body"]  as? String ?? ""
    let content = UNMutableNotificationContent()
    content.title = title
    content.body  = body
    content.sound = .default
    let request = UNNotificationRequest(
      identifier: "demo-\(Date().timeIntervalSince1970)",
      content: content,
      trigger: nil
    )
    UNUserNotificationCenter.current().add(request)
    result(nil)
  }

  // MARK: - Cry notification (banner, not CallKit)

  private func handleReportCry(_ arguments: Any?, result: @escaping FlutterResult) {
    // When a monitor Live Activity is running, AlertConfiguration already handles
    // lock-screen sound + DI expansion. Firing a separate banner would duplicate the alert.
    // Only fire the banner as a fallback when no monitor LA is active.
    let hasActiveMonitor: Bool
    if #available(iOS 16.2, *) {
      hasActiveMonitor = monitorActivity != nil || monitorActivityB != nil
    } else {
      hasActiveMonitor = false
    }

    if !hasActiveMonitor {
      let babyName = (arguments as? [String: Any])?["babyName"] as? String ?? "Baby"
      let content = UNMutableNotificationContent()
      content.title = "\(babyName) is crying"
      content.body  = "Sound detected — open the app to listen."
      content.sound = .default
      let request = UNNotificationRequest(
        identifier: "cry-\(Date().timeIntervalSince1970)",
        content: content,
        trigger: nil
      )
      UNUserNotificationCenter.current().add(request)
    }

    callEventSink?("crying")
    result(nil)
  }
}

// MARK: - FlutterStreamHandler

extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    callEventSink = events
    events("idle")
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    callEventSink = nil
    return nil
  }
}
