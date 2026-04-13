import AVFoundation
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
  private var isPlaying = true
  private var channel: FlutterMethodChannel?

  init(frame: CGRect, messenger: FlutterBinaryMessenger) {
    super.init()

    hostView.backgroundColor = .black
    hostView.playerLayer.videoGravity = .resizeAspectFill

    setupPlayer()
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
      case "startPip", "stopPip":
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { hostView }

  // MARK: Private

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

  private func setupGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    hostView.addGestureRecognizer(tap)
    hostView.isUserInteractionEnabled = true
  }

  @objc private func handleTap() {
    if isPlaying {
      player?.pause()
      isPlaying = false
    } else {
      player?.play()
      isPlaying = true
    }
    // Notify Flutter so it can show the play/pause overlay icon
    channel?.invokeMethod("playStateChanged", arguments: isPlaying)
  }
}
