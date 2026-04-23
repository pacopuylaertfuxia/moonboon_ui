import ActivityKit
import AppIntents
import Foundation

// Intent that runs inside the widget-extension process when the parent taps
// the play/stop button in the Dynamic Island expanded view.
//
// Flow:
//   1. Flip "isCryPlaying" flag in shared App Group UserDefaults
//   2. Update ContentState on every active monitor activity so the DI
//      button icon changes immediately (▶ ↔ ⏸) without waiting for the app
//   3. AppDelegate 300 ms polling timer reads the flag and plays/stops the MP3

@available(iOS 16.2, *)
struct ToggleCryAudioIntent: AppIntent {

    static var title: LocalizedStringResource = "Toggle cry audio"

    private let kAppGroup = "group.com.moonboon.moonboonUi"
    private let kFlagKey  = "isCryPlaying"

    func perform() async throws -> some IntentResult {
        let defaults  = UserDefaults(suiteName: kAppGroup)
        let current   = defaults?.bool(forKey: kFlagKey) ?? false
        let newValue  = !current
        defaults?.set(newValue, forKey: kFlagKey)
        defaults?.synchronize()  // flush to disk so the app process reads the new value immediately

        // Update all running monitor activities so the button state flips immediately
        for activity in Activity<MoonboonActivityAttributes>.activities {
            var s = activity.content.state
            s.isPlayingCry = newValue
            await activity.update(ActivityContent(state: s, staleDate: nil))
        }

        return .result()
    }
}
