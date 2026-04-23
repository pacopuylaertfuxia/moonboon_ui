import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Native video player — drives the monitor stream preview + PiP
    if let videoRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativeVideoPlayer") {
      videoRegistrar.register(
        NativeVideoPlayerFactory(messenger: videoRegistrar.messenger()),
        withId: "com.moonboon/native_video_player"
      )
    }
  }
}
