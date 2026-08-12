import SwiftUI
import WidgetKit

// ── App Group image helpers ───────────────────────────────────────────────────

private let kV8AppGroup   = "group.com.moonboon.moonboonUi"
private let kV8FrameFile  = "live_feed_frame.jpg"

private func v8CachedFrame() -> UIImage? {
    guard let url = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: kV8AppGroup)?
        .appendingPathComponent(kV8FrameFile),
          let data = try? Data(contentsOf: url)
    else { return nil }
    return UIImage(data: data)
}

// ── Shared monitor device icon ────────────────────────────────────────────────
// Uses the same "monitor" named image as MonitorCompactLeading.
// Falls back to a clay circle so the widget never breaks.

private struct V8DeviceIcon: View {
    var size: CGFloat = 22

    var body: some View {
        Group {
            if let img = UIImage(named: "monitor") {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(MB.clay.opacity(0.25))
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .font(.system(size: size * 0.45))
                            .foregroundColor(MB.clay)
                    )
            }
        }
    }
}

// ── Status helpers ────────────────────────────────────────────────────────────

private func v8DisplayStatus(_ label: String) -> String {
    switch label {
    case "Sleeping":    return "Quiet"
    case "Monitoring":  return "Active"
    case "Crying":      return "Crying"
    default:            return label
    }
}

private func v8StatusDotColor(_ label: String) -> Color {
    switch label {
    case "Crying":  return Color.red
    case "Awake":   return MB.clay
    default:        return Color(hex: "#34C759")
    }
}

private func v8BatteryIcon(level: Int, charging: Bool) -> String {
    if charging    { return "battery.100.bolt" }
    if level > 75  { return "battery.100" }
    if level > 50  { return "battery.75" }
    if level > 25  { return "battery.50" }
    return "battery.25"
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPACT — Leading: monitor icon with pulse ring (matches MonitorCompactLeading)
// ─────────────────────────────────────────────────────────────────────────────

struct V8CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(MB.clay.opacity(pulse ? 0.0 : 0.5), lineWidth: 1.5)
                .frame(width: 32, height: 32)
                .scaleEffect(pulse ? 1.6 : 1.0)
                .animation(
                    .easeOut(duration: 1.6).repeatForever(autoreverses: false),
                    value: pulse
                )
            V8DeviceIcon(size: 22)
        }
        .padding(.leading, 4)
        .onAppear { pulse = true }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPACT — Trailing: spring-animated bars
// ─────────────────────────────────────────────────────────────────────────────

struct V8CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        LiveWaveformBars(
            soundLevel: max(state.soundLevel, 0.18),
            barCount: 5, maxHeight: 14,
            barWidth: 4, spacing: 2,
            color: MB.clay
        )
        .padding(.trailing, 4)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDED — Leading: [device icon · bars] beside the camera
// Kept intentionally short so the expanded card is nearly the same height
// as the compact pill — a "wide pill" rather than a tall card.
// ─────────────────────────────────────────────────────────────────────────────

struct V8ExpandedLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 7) {
            V8DeviceIcon(size: 22)
            LiveWaveformBars(
                soundLevel: max(state.soundLevel, 0.15),
                barCount: 6, maxHeight: 16,
                barWidth: 4, spacing: 2,
                color: MB.clay
            )
        }
        .padding(.leading, 4)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDED — Trailing: status text with crossfade on change
// ─────────────────────────────────────────────────────────────────────────────

struct V8ExpandedTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 5) {
            // Colored status dot
            Circle()
                .fill(v8StatusDotColor(state.statusLabel))
                .frame(width: 6, height: 6)
                .animation(.easeInOut(duration: 0.4), value: state.statusLabel)

            // Status label — crossfades on change
            Text(v8DisplayStatus(state.statusLabel))
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.35), value: state.statusLabel)
        }
        .padding(.trailing, 6)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MINIMAL
// ─────────────────────────────────────────────────────────────────────────────

struct V8Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Circle()
            .fill(v8StatusDotColor(state.statusLabel))
            .frame(width: 6, height: 6)
            .animation(.easeInOut(duration: 0.4), value: state.statusLabel)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCK SCREEN — images + battery on top, waveform + status below
// ─────────────────────────────────────────────────────────────────────────────

struct V8LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 0) {

            // ── Top bar: device icon · name · status · battery/wifi ──────────
            HStack(spacing: 10) {
                // Device icon
                V8DeviceIcon(size: 36)

                // Baby name + status
                VStack(alignment: .leading, spacing: 1) {
                    Text(attrs.babyName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MB.textDark)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(v8StatusDotColor(state.statusLabel))
                            .frame(width: 6, height: 6)
                        Text(v8DisplayStatus(state.statusLabel))
                            .font(.system(size: 12))
                            .foregroundColor(MB.olive)
                            .contentTransition(.opacity)
                            .animation(.easeInOut(duration: 0.4), value: state.statusLabel)
                    }
                }

                Spacer()

                // Battery
                HStack(spacing: 3) {
                    Image(systemName: v8BatteryIcon(level: state.batteryLevel, charging: state.isCharging))
                        .font(.system(size: 13))
                        .foregroundColor(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging))
                    Text("\(state.batteryLevel)%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(MB.textSecondary)
                }

                // WiFi
                Image(systemName: state.wifiStrength > 0.5 ? "wifi" : "wifi.exclamationmark")
                    .font(.system(size: 11))
                    .foregroundColor(state.connectionState == "connected" ? MB.clay : .red)

                // Camera thumbnail (if feed available)
                if let frame = v8CachedFrame() {
                    Image(uiImage: frame)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // ── Divider ───────────────────────────────────────────────────────
            Rectangle()
                .fill(MB.clay.opacity(0.15))
                .frame(height: 0.5)
                .padding(.horizontal, 16)
                .padding(.top, 10)

            // ── Waveform ──────────────────────────────────────────────────────
            LiveWaveformBars(
                soundLevel: state.soundLevel,
                barCount: 28, maxHeight: 24,
                barWidth: 4, spacing: 2,
                color: MB.clay
            )
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // ── Bottom meta row ───────────────────────────────────────────────
            HStack(spacing: 12) {
                // Elapsed
                Label(MB.formatElapsed(state.elapsedSeconds), systemImage: "clock")
                    .font(.system(size: 11))
                    .foregroundColor(MB.olive)

                // Temperature
                if let temp = state.temperature {
                    Label("\(temp)°C", systemImage: "thermometer.medium")
                        .font(.system(size: 11))
                        .foregroundColor(MB.olive)
                }

                // Nap
                if let nap = state.napSeconds, nap > 60 {
                    Label("\(nap / 60)m quiet", systemImage: "moon.fill")
                        .font(.system(size: 11))
                        .foregroundColor(MB.olive)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 14)
        }
        .background(MB.creme)
    }
}
