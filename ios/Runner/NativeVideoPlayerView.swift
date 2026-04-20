import AVFoundation
import AVKit
import Flutter
import UIKit

// MARK: - Factory

class NativeVideoPlayerFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    return NativeVideoPlayerView(frame: frame, messenger: messenger)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

// MARK: - Player-backed UIView (AVPlayerLayer as layer class — auto-resizes, no tone mapping)

private class _PlayerView: UIView {
  override class var layerClass: AnyClass { AVPlayerLayer.self }
  var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

// MARK: - Platform view

class NativeVideoPlayerView: NSObject, FlutterPlatformView {
  private let hostView = _PlayerView()
  private var player: AVPlayer?
  private var pipController: AVPictureInPictureController?
  private var isPlaying = true
  private var channel: FlutterMethodChannel?

  init(frame: CGRect, messenger: FlutterBinaryMessenger) {
    super.init()

    hostView.backgroundColor = .black
    hostView.playerLayer.videoGravity = .resizeAspectFill

    setupAudioSession()
    setupPlayer()
    setupPip()
    setupGesture()

    let ch = FlutterMethodChannel(
      name: "com.moonboon/video_player",
      binaryMessenger: messenger
    )
    self.channel = ch
    ch.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "play":
        self?.player?.play()
        self?.isPlaying = true
        result(nil)
      case "pause":
        self?.player?.pause()
        self?.isPlaying = false
        result(nil)
      case "startPip":
        self?.startPip(result: result)
      case "stopPip":
        self?.pipController?.stopPictureInPicture()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { hostView }

  // MARK: Private — setup

  private func setupAudioSession() {
    // PiP requires an active .playback session — set it here so PiP works
    // even when no Live Activity is running (keep-alive not yet started).
    try? AVAudioSession.sharedInstance().setCategory(
      .playback, mode: .default, options: .mixWithOthers)
    try? AVAudioSession.sharedInstance().setActive(true)
  }

  private func setupPlayer() {
    guard let url = Bundle.main.url(forResource: "sample", withExtension: "mov") else {
      print("[VideoPlayer] sample.mov not found in bundle")
      return
    }

    let item = AVPlayerItem(url: url)
    let player = AVPlayer(playerItem: item)
    player.actionAtItemEnd = .none

    NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: item,
      queue: .main
    ) { [weak player] _ in
      player?.seek(to: .zero)
      player?.play()
    }

    hostView.playerLayer.player = player
    self.player = player
    player.play()
  }

  private func setupPip() {
    guard AVPictureInPictureController.isPictureInPictureSupported(),
          let pip = AVPictureInPictureController(playerLayer: hostView.playerLayer)
    else {
      print("[VideoPlayer] PiP not supported on this device/OS")
      return
    }
    pip.delegate = self
    if #available(iOS 14.2, *) {
      pip.canStartPictureInPictureAutomaticallyFromInline = false
    }

    self.pipController = pip
  }

  private func setupGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    hostView.addGestureRecognizer(tap)
    hostView.isUserInteractionEnabled = true
  }

  // MARK: Private — actions

  private func startPip(result: @escaping FlutterResult) {
    guard let pip = pipController else {
      result(FlutterError(code: "PIP_UNAVAILABLE", message: "PiP not supported", details: nil))
      return
    }
    if pip.isPictureInPictureActive {
      result(nil)
      return
    }
    // isPictureInPicturePossible may be false briefly after player init —
    // wait up to 2s for it to become ready.
    if pip.isPictureInPicturePossible {
      pip.startPictureInPicture()
      result(nil)
    } else {
      waitForPipReady(pip: pip, result: result)
    }
  }

  private func waitForPipReady(pip: AVPictureInPictureController, result: @escaping FlutterResult, attempts: Int = 0) {
    guard attempts < 10 else {
      result(FlutterError(code: "PIP_NOT_READY", message: "PiP not ready", details: nil))
      return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak pip] in
      guard let pip else { return }
      if pip.isPictureInPicturePossible {
        pip.startPictureInPicture()
        result(nil)
      } else {
        self.waitForPipReady(pip: pip, result: result, attempts: attempts + 1)
      }
    }
  }

  @objc private func handleTap() {
    if isPlaying {
      player?.pause()
      isPlaying = false
    } else {
      player?.play()
      isPlaying = true
    }
    channel?.invokeMethod("playStateChanged", arguments: isPlaying)
  }
}

// MARK: - AVPictureInPictureControllerDelegate

extension NativeVideoPlayerView: AVPictureInPictureControllerDelegate {
  func pictureInPictureControllerWillStartPictureInPicture(_ controller: AVPictureInPictureController) {
    channel?.invokeMethod("pipStateChanged", arguments: true)
  }

  func pictureInPictureControllerDidStopPictureInPicture(_ controller: AVPictureInPictureController) {
    channel?.invokeMethod("pipStateChanged", arguments: false)
  }

  func pictureInPictureController(
    _ controller: AVPictureInPictureController,
    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
  ) {
    // Called when user taps the PiP restore button — just restore the UI
    completionHandler(true)
  }
}
