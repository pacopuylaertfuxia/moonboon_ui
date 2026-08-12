import ActivityKit
import Foundation

struct MotorActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var isRunning: Bool
        var program: String        // "Gentle" | "Medium" | "Strong"
        var speed: Int             // 1–10
        var remainingSeconds: Int? // nil = no countdown
        var batteryLevel: Int      // 0–100
        var isCharging: Bool
    }
    var motorName: String
}
