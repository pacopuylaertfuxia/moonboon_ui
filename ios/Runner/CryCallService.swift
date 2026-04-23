import AVFoundation
import CallKit
import Foundation

// Emits call state back to Flutter
typealias CallStateHandler = (String) -> Void  // "ringing" | "answered" | "ended"

class CryCallService: NSObject, CXProviderDelegate {
  static let shared = CryCallService()

  private let provider: CXProvider
  private let callController = CXCallController()
  private(set) var currentCallUUID: UUID?
  private(set) var callState: String = "idle"  // "idle" | "ringing" | "answered" | "ended"

  var onStateChanged: CallStateHandler?

  // Quiet-end timer: call ends automatically when sound is low for this long
  private var quietTimer: Timer?
  static let quietTimeoutSeconds: Double = 8.0

  private override init() {
    let config = CXProviderConfiguration(localizedName: "Moonboon Monitor")
    config.supportsVideo = false
    config.maximumCallGroups = 1
    config.maximumCallsPerCallGroup = 1
    config.ringtoneSound = nil  // system default ring

    provider = CXProvider(configuration: config)
    super.init()
    provider.setDelegate(self, queue: .main)
  }

  // MARK: - Report incoming cry

  func reportIncomingCry(babyName: String) {
    // End any active call first
    if let existing = currentCallUUID {
      _endCall(uuid: existing)
    }

    let uuid = UUID()
    currentCallUUID = uuid

    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .generic, value: babyName)
    update.localizedCallerName = "🌙 \(babyName) — sound detected"
    update.hasVideo = false

    provider.reportNewIncomingCall(with: uuid, update: update) { [weak self] error in
      DispatchQueue.main.async {
        if let error = error {
          print("[CryCall] Failed to report: \(error.localizedDescription)")
          self?.currentCallUUID = nil
        } else {
          self?._setState("ringing")
        }
      }
    }
  }

  // MARK: - End call

  func endCall() {
    guard let uuid = currentCallUUID else { return }
    _endCall(uuid: uuid)
  }

  private func _endCall(uuid: UUID) {
    quietTimer?.invalidate()
    quietTimer = nil
    let action = CXEndCallAction(call: uuid)
    callController.request(CXTransaction(action: action)) { _ in }
    // State update happens in delegate
  }

  // MARK: - Quiet timer (auto-end when baby is quiet)

  func soundLevelUpdated(_ level: Double) {
    guard callState == "answered" else { return }
    let threshold = 0.15

    if level < threshold {
      // Start quiet timer if not already running
      if quietTimer == nil {
        quietTimer = Timer.scheduledTimer(
          withTimeInterval: CryCallService.quietTimeoutSeconds,
          repeats: false
        ) { [weak self] _ in
          self?.endCall()
        }
      }
    } else {
      // Still loud — cancel quiet timer
      quietTimer?.invalidate()
      quietTimer = nil
    }
  }

  var quietTimerRemaining: Double? {
    // Approximate remaining time for UI progress bar
    guard let timer = quietTimer else { return nil }
    return max(0, timer.fireDate.timeIntervalSinceNow)
  }

  // MARK: - CXProviderDelegate

  func providerDidReset(_ provider: CXProvider) {
    currentCallUUID = nil
    quietTimer?.invalidate()
    quietTimer = nil
    _setState("idle")
  }

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    // Activate audio session for baby monitor audio
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
    try? session.setActive(true)
    action.fulfill()
    _setState("answered")
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    let session = AVAudioSession.sharedInstance()
    try? session.setActive(false, options: .notifyOthersOnDeactivation)
    currentCallUUID = nil
    quietTimer?.invalidate()
    quietTimer = nil
    action.fulfill()
    _setState("ended")
    // Reset to idle after brief delay so Flutter can read "ended"
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self._setState("idle")
    }
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    // Audio route is active — real app would start streaming here
    print("[CryCall] Audio session activated — ready for baby monitor stream")
  }

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    print("[CryCall] Audio session deactivated")
  }

  // MARK: - Private

  private func _setState(_ state: String) {
    callState = state
    onStateChanged?(state)
  }
}
