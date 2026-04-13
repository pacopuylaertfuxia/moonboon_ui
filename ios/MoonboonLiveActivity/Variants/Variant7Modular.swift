import SwiftUI
import WidgetKit

// ── Palette ───────────────────────────────────────────────────────────────────
private let clay    = Color(red: 0.710, green: 0.620, blue: 0.522) // #B59E85
private let cream   = Color(red: 0.945, green: 0.910, blue: 0.870) // #F1E8DE
private let bg      = Color(red: 0.059, green: 0.051, blue: 0.043) // #0F0D0B
private let surface = Color(red: 0.118, green: 0.102, blue: 0.086) // #1E1A16
private let card    = Color(red: 0.180, green: 0.157, blue: 0.125) // #2E2820
private let txtPri  = Color(red: 0.961, green: 0.953, blue: 0.945) // #F5F3F1
private let txtSec  = Color(red: 0.769, green: 0.667, blue: 0.557) // #C4AA8E
private let txtTer  = Color(red: 0.549, green: 0.506, blue: 0.471) // #8C8178
private let green   = Color(red: 0.204, green: 0.780, blue: 0.349) // #34C759
private let red     = Color(red: 1.000, green: 0.231, blue: 0.188) // #FF3B30
private let orange  = Color(red: 1.000, green: 0.584, blue: 0.000) // #FF9500

// ── Helpers ───────────────────────────────────────────────────────────────────

private func napLabel(_ s: Int?) -> String {
    guard let s = s, s > 0 else { return "" }
    if s < 60  { return "quiet \(s)s" }
    if s < 3600 { return "quiet \(s/60)m" }
    return "quiet \(s/3600)h \((s%3600)/60)m"
}

private func elapsedLabel(_ s: Int) -> String {
    if s < 60   { return "\(s)s" }
    if s < 3600 { return "\(s/60)m" }
    return "\(s/3600)h \((s%3600)/60)m"
}

private func wifiIcon(_ w: Double) -> String {
    if w < 0.33 { return "wifi.slash" }
    if w < 0.66 { return "wifi.exclamationmark" }
    return "wifi"
}

private func batteryIcon(level: Int, charging: Bool) -> String {
    if charging { return "battery.100.bolt" }
    if level > 75 { return "battery.100" }
    if level > 50 { return "battery.75" }
    if level > 25 { return "battery.50" }
    return "battery.25"
}

private func batteryColor(level: Int, charging: Bool) -> Color {
    if charging { return green }
    if level > 25 { return txtSec }
    return red
}

private func statusColor(_ label: String) -> Color {
    if label == "Crying" { return red }
    if label == "Awake"  { return orange }
    return green
}

// ── Mini sound bar ────────────────────────────────────────────────────────────

private struct MiniSoundBar: View {
    let level: Double
    var body: some View {
        HStack(spacing: 1.5) {
            ForEach(0..<7, id: \.self) { i in
                let wave = i % 3 == 0 ? 1.0 : i % 3 == 1 ? 0.55 : 0.3
                let h = clamp(CGFloat(3 + wave * level * 14), 2, 16)
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.lerp(clay, red, t: level))
                    .frame(width: 2, height: h)
            }
        }
        .frame(height: 16)
    }
}

private extension Color {
    static func lerp(_ a: Color, _ b: Color, t: Double) -> Color {
        // Simple lerp via UIColor components
        let t = min(max(t, 0), 1)
        return Color(
            red:   a.components.r * (1-t) + b.components.r * t,
            green: a.components.g * (1-t) + b.components.g * t,
            blue:  a.components.b * (1-t) + b.components.b * t
        )
    }
    var components: (r: Double, g: Double, b: Double) {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: nil)
        return (Double(r), Double(g), Double(b))
    }
}

private func clamp(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
    Swift.min(Swift.max(v, lo), hi)
}

// ── Pill chip ─────────────────────────────────────────────────────────────────

private struct Chip: View {
    let icon: String
    let label: String
    var accent: Color = clay
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(accent)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(txtSec)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(card)
        .clipShape(Capsule())
    }
}

// ── Lock screen widget ────────────────────────────────────────────────────────

struct V7LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var isCrying: Bool { state.soundLevel > 0.15 }
    var statusColor: Color { Self.statusColorFor(state.statusLabel, crying: isCrying) }
    static func statusColorFor(_ label: String, crying: Bool) -> Color {
        if crying || label == "Crying" { return red }
        if label == "Awake" { return orange }
        return green
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Row 1: name + status + elapsed ───────────────────────
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 7, height: 7)
                Text(attrs.babyName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(txtPri)
                Text(isCrying ? "Sound detected" : state.napSeconds != nil ? napLabel(state.napSeconds) : "Quiet")
                    .font(.system(size: 12))
                    .foregroundColor(txtSec)
                Spacer()
                Text(elapsedLabel(state.elapsedSeconds))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(txtTer)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            // ── Row 2: sound bar (only when crying) + temp + humidity ─
            HStack(spacing: 10) {
                if isCrying {
                    MiniSoundBar(level: state.soundLevel)
                }
                Spacer()
                if let temp = state.temperature {
                    Chip(icon: "thermometer.medium", label: "\(temp)°C")
                }
                if let hum = state.humidity {
                    Chip(icon: "humidity", label: "\(hum)%")
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 7)

            // ── Divider ───────────────────────────────────────────────
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 0.5)
                .padding(.horizontal, 14)
                .padding(.top, 8)

            // ── Row 3: motor · monitor mode · battery · wifi ──────────
            HStack(spacing: 6) {
                // Motor
                Chip(
                    icon: state.motorRunning ? "rotate.3d" : "rotate.3d",
                    label: state.motorRunning
                        ? "Motor · \(state.motorProgram.isEmpty ? "On" : state.motorProgram)"
                        : "Motor off",
                    accent: state.motorRunning ? clay : txtTer
                )

                // Monitor mode
                Chip(
                    icon: state.monitorOn ? "mic.fill" : "mic.slash.fill",
                    label: state.monitorOn ? state.monitorMode : "Monitor off",
                    accent: state.monitorOn ? green : txtTer
                )

                Spacer()

                // Battery
                Image(systemName: batteryIcon(level: state.batteryLevel, charging: state.isCharging))
                    .font(.system(size: 12))
                    .foregroundColor(batteryColor(level: state.batteryLevel, charging: state.isCharging))
                Text("\(state.batteryLevel)%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(txtTer)

                // WiFi
                Image(systemName: wifiIcon(state.wifiStrength))
                    .font(.system(size: 11))
                    .foregroundColor(state.connectionState == "connected" ? txtSec : red)
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .background(bg)
    }
}

// ── Dynamic Island expanded ───────────────────────────────────────────────────

struct V7Expanded: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState
    var isCrying: Bool { state.soundLevel > 0.15 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(isCrying ? red : green)
                    .frame(width: 8, height: 8)
                Text(attrs.babyName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(txtPri)
                Text(isCrying ? "Sound detected" : napLabel(state.napSeconds))
                    .font(.system(size: 12))
                    .foregroundColor(txtSec)
                Spacer()
                if isCrying { MiniSoundBar(level: state.soundLevel) }
            }
            HStack(spacing: 8) {
                Label(state.motorRunning ? "Motor · \(state.motorProgram)" : "Motor off",
                      systemImage: "rotate.3d")
                    .font(.system(size: 11))
                    .foregroundColor(state.motorRunning ? clay : txtTer)
                Label(state.monitorOn ? state.monitorMode : "Monitor off",
                      systemImage: state.monitorOn ? "mic.fill" : "mic.slash.fill")
                    .font(.system(size: 11))
                    .foregroundColor(state.monitorOn ? green : txtTer)
                Spacer()
                if let t = state.temperature {
                    Text("\(t)°")
                        .font(.system(size: 11))
                        .foregroundColor(txtSec)
                }
                Image(systemName: batteryIcon(level: state.batteryLevel, charging: state.isCharging))
                    .font(.system(size: 11))
                    .foregroundColor(batteryColor(level: state.batteryLevel, charging: state.isCharging))
            }
        }
        .padding(.horizontal, 4)
    }
}

// ── Compact ───────────────────────────────────────────────────────────────────

struct V7CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState
    var isCrying: Bool { state.soundLevel > 0.15 }
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isCrying ? red : green)
                .frame(width: 6, height: 6)
            if isCrying {
                MiniSoundBar(level: state.soundLevel)
            } else {
                Image(systemName: state.motorRunning ? "rotate.3d" : "moon.zzz.fill")
                    .font(.system(size: 10))
                    .foregroundColor(state.motorRunning ? clay : txtSec)
            }
        }
    }
}

struct V7CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: batteryIcon(level: state.batteryLevel, charging: state.isCharging))
                .font(.system(size: 10))
                .foregroundColor(batteryColor(level: state.batteryLevel, charging: state.isCharging))
            Text("\(state.batteryLevel)%")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(txtTer)
        }
    }
}

struct V7Minimal: View {
    let state: MoonboonActivityAttributes.ContentState
    var isCrying: Bool { state.soundLevel > 0.15 }
    var body: some View {
        Circle()
            .fill(isCrying ? red : green)
            .frame(width: 6, height: 6)
    }
}
