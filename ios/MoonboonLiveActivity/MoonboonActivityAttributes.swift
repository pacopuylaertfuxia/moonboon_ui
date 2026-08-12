import ActivityKit
import Foundation

struct MoonboonActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var soundLevel: Double       // 0.0–1.0
        var isMicMuted: Bool
        var temperature: Int?        // nil = no sensor
        var batteryLevel: Int        // 0–100
        var isCharging: Bool
        var statusLabel: String      // "Sleeping" | "Awake" | "Crying"
        var connectionState: String  // "connected" | "disconnected"
        var wifiStrength: Double     // 0.0–1.0
        var elapsedSeconds: Int      // seconds since activity started

        // ── Modular fields (Variant 7) ──────────────────────────────────
        var motorRunning: Bool       // is the motor/bouncer on?
        var motorProgram: String     // "Quick" | "Medium" | "Long" | ""
        var monitorOn: Bool          // is the monitor streaming?
        var monitorMode: String      // "Quiet" | "Standard" | "Maximum" | "Off"
        var humidity: Int?           // % relative humidity
        var napSeconds: Int?         // seconds baby has been quiet/napping
        var hasCameraFeed: Bool      // true = widget reads frame from App Group container
        var isPlayingCry: Bool       // true = parent tapped play in DI — audio playing in app

        init(
            soundLevel: Double, isMicMuted: Bool, temperature: Int?,
            batteryLevel: Int, isCharging: Bool, statusLabel: String,
            connectionState: String, wifiStrength: Double, elapsedSeconds: Int,
            motorRunning: Bool = false, motorProgram: String = "",
            monitorOn: Bool = true, monitorMode: String = "Standard",
            humidity: Int? = nil, napSeconds: Int? = nil,
            hasCameraFeed: Bool = false, isPlayingCry: Bool = false
        ) {
            self.soundLevel      = soundLevel
            self.isMicMuted      = isMicMuted
            self.temperature     = temperature
            self.batteryLevel    = batteryLevel
            self.isCharging      = isCharging
            self.statusLabel     = statusLabel
            self.connectionState = connectionState
            self.wifiStrength    = wifiStrength
            self.elapsedSeconds  = elapsedSeconds
            self.motorRunning    = motorRunning
            self.motorProgram    = motorProgram
            self.monitorOn       = monitorOn
            self.monitorMode     = monitorMode
            self.humidity        = humidity
            self.napSeconds      = napSeconds
            self.hasCameraFeed   = hasCameraFeed
            self.isPlayingCry    = isPlayingCry
        }
    }

    var babyName: String
    var designVariant: Int  // 1–6 legacy, 7 = modular
}
