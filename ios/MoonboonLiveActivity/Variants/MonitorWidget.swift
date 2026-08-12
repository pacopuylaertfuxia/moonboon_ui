import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live animated waveform

// Per-bar personality: controls max height reactivity and animation speed
private let kPersonality: [Double] = [
    0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.4, 1.0, 0.5, 0.7,
    0.8, 0.4, 0.9, 0.6, 0.5, 0.7, 1.0, 0.4, 0.8, 0.6,
    0.5, 0.9, 0.7, 0.4,
]

/// Sound-reactive bars — height tracks soundLevel directly.
/// Each Flutter update animates bars to their new target via spring.
struct LiveWaveformBars: View {
    let soundLevel: Double   // 0.0–1.0
    let barCount: Int
    let maxHeight: CGFloat
    let barWidth: CGFloat
    let spacing: CGFloat
    let color: Color

    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            ForEach(0..<barCount, id: \.self) { i in
                let p = kPersonality[i % kPersonality.count]
                // Floor so a bar is always visible (3–5 pt)
                let floor = CGFloat(3.0 + p * 2.0)
                // Target scales with both level and per-bar personality
                let target = floor + CGFloat(soundLevel * p * Double(maxHeight - floor))

                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(color.opacity(0.45 + soundLevel * 0.55))
                    .frame(width: barWidth, height: target)
                    // Spring gives a natural snap-and-bounce feel on each update
                    .animation(
                        .interpolatingSpring(stiffness: 180, damping: 14)
                        .delay(Double(i) * 0.015),  // stagger so bars don't move in lockstep
                        value: soundLevel
                    )
            }
        }
        .frame(height: maxHeight)
    }
}

// MARK: - Shared App Group helper

private let kAppGroup    = "group.com.moonboon.moonboonUi"
private let kFrameFile   = "live_feed_frame.jpg"
private let kMonitorFile = "monitor_icon.png"

private func cachedImage(named fileName: String) -> UIImage? {
    guard let containerURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: kAppGroup) else { return nil }
    let fileURL = containerURL.appendingPathComponent(fileName)
    guard let data = try? Data(contentsOf: fileURL) else { return nil }
    return UIImage(data: data)
}

/// Baby photo: live App Group frame → fallback to bundled baby.png
private func cameraFrameOrSample() -> UIImage? {
    cachedImage(named: kFrameFile) ?? UIImage(named: "baby")
}

/// Monitor device icon: live App Group image → fallback to bundled monitor.png
private func monitorIcon() -> UIImage? {
    cachedImage(named: kMonitorFile) ?? UIImage(named: "monitor")
}

// MARK: - Lock Screen
// Figma 7:632 — cream bg, left col vertically centered (x=32 w=166), thumbnail top-pinned (x=225 128×128 r=31)

struct MonitorLockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(alignment: .center, spacing: 0) {

            // ── Left column — x=32, w=166, vertically centred by HStack ──
            VStack(alignment: .leading, spacing: 9) {

                // "Your baby is" / Kepler status
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your baby is")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(MB.olive)                       // #70695F

                    Text(state.statusLabel == "Sleeping"    ? "Quiet" :
                         state.statusLabel == "Monitoring"  ? "Active" :
                         state.statusLabel == "Crying"      ? "Crying" : "Awake")
                        .font(.custom("KeplerStd-Disp", size: 38))
                        .foregroundColor(MB.textSecondary)               // #464545
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.4), value: state.statusLabel)
                }

                // Clay waveform — 24 bars × 5pt × 2pt gap, max 28pt (matches Figma crying state)
                LiveWaveformBars(
                    soundLevel: state.soundLevel,
                    barCount: 24, maxHeight: 28,
                    barWidth: 5, spacing: 2,
                    color: MB.clay
                )

                // Metrics row — gap=8: [monitor 24×24] [battery icon + %] [temp°]
                HStack(spacing: 8) {
                    // Monitor device photo (same asset as compact pill)
                    Group {
                        if let icon = monitorIcon() {
                            Image(uiImage: icon)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                        } else {
                            Circle().fill(MB.clay).frame(width: 24, height: 24)
                        }
                    }

                    // Battery icon + percentage — SF Medium 14pt #464545
                    HStack(spacing: 4) {
                        Image(systemName: state.isCharging ? "battery.100.bolt" : "battery.75")
                            .font(.system(size: 11))
                            .foregroundColor(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging))
                        Text("\(state.batteryLevel)%")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(MB.textSecondary)
                    }

                    // Temperature — SF Medium 14pt #464545
                    if let temp = state.temperature {
                        Text("\(temp)°")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(MB.textSecondary)
                    }
                }
            }
            .frame(width: 166)
            .padding(.leading, 32)

            Spacer()

            // ── Thumbnail — GeometryReader measures actual card height, sizes image
            // to (height - 2×pad) so all four paddings are exactly equal.
            // aspectRatio(1, .fit) makes the container square = card height × card height.
            if let frame = cameraFrameOrSample() {
                GeometryReader { geo in
                    let pad: CGFloat = 13
                    let size = max(geo.size.height - pad * 2, 0)
                    Image(uiImage: frame)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: size * 0.24))
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .aspectRatio(1, contentMode: .fit)   // width = height = card height
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MB.apricot)
    }
}

// MARK: - Dynamic Island: Compact

struct MonitorCompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        // Icon flush to left margin — same 4pt clearance as top/bottom (Apple guideline)
        Group {
            if let icon = monitorIcon() {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
            } else {
                Circle().fill(MB.clay).frame(width: 24, height: 24)
            }
        }
        // Green live dot — top-right corner of icon
        .overlay(
            Circle()
                .fill(Color(red: 0.204, green: 0.780, blue: 0.349))
                .frame(width: 7, height: 7)
                .overlay(Circle().stroke(Color.black.opacity(0.8), lineWidth: 1.5).frame(width: 7, height: 7)),
            alignment: .topTrailing
        )
        .padding(.leading, 4)
    }
}

struct MonitorCompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        // Always-on bars — iOS call indicator style.
        // Floor at 0.18 keeps bars alive even when quiet; spring tracks sound level.
        LiveWaveformBars(
            soundLevel: max(state.soundLevel, 0.18),
            barCount: 5, maxHeight: 14,
            barWidth: 4, spacing: 2,
            color: MB.clay
        )
        .padding(.trailing, 4)
    }
}

// MARK: - Dynamic Island: Expanded
// Figma spec (node 7:710): card 374×147pt, black bg, radius 48
// .leading region: left column x=32, w=166, vertically centred — sits LEFT of sensor pill
// .trailing region: thumbnail 105×105, r=25, top=21 — sits RIGHT of sensor pill

/// Left region — text column + waveform, vertically centred beside the sensor pill
/// The .leading region is ~120pt wide on iPhone 14 Pro — keep padding tight.
struct MonitorExpandedLeading: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer(minLength: 0)

            // "Your baby is" — must stay on one line; region is narrow
            Text("Your baby is")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(MB.apricot)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)

            // Kepler status
            Text(state.statusLabel == "Sleeping"    ? "Quiet" :
                 state.statusLabel == "Monitoring"  ? "Active" :
                 state.statusLabel == "Crying"      ? "Crying" : "Awake")
                .font(.custom("KeplerStd-Disp", size: 36))
                .foregroundColor(MB.clay)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.4), value: state.statusLabel)

            // Waveform — grey, 12 bars × 5pt × 2pt = 82pt total, fits the leading region
            LiveWaveformBars(
                soundLevel: state.soundLevel,
                barCount: 12, maxHeight: 14,
                barWidth: 5, spacing: 2,
                color: Color(red: 0.851, green: 0.851, blue: 0.851)
            )

            // Play/stop button — shown inline when Crying, iOS 17+
            if state.statusLabel == "Crying" {
                if #available(iOS 17.0, *) {
                    Button(intent: ToggleCryAudioIntent()) {
                        HStack(spacing: 6) {
                            Image(systemName: state.isPlayingCry ? "stop.fill" : "play.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text(state.isPlayingCry ? "Stop" : "Listen")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(state.isPlayingCry ? MB.clay : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(
                                state.isPlayingCry
                                    ? MB.clay.opacity(0.22)
                                    : Color.white.opacity(0.15)
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.leading, 8)
        .padding(.trailing, 4)
    }
}

/// Right region — baby thumbnail, equal padding all sides
/// HStack/region centers it vertically; uniform padding prevents overflow on short cards
struct MonitorExpandedTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        if let frame = cameraFrameOrSample() {
            Image(uiImage: frame)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(12)   // equal 12pt all sides
        }
    }
}

// MARK: - Dynamic Island: Minimal

struct MonitorMinimal: View {
    let state: MoonboonActivityAttributes.ContentState
    var body: some View {
        Circle()
            .fill(MB.statusColor(state.statusLabel))
            .frame(width: 10, height: 10)
    }
}

// MARK: - Shared sub-views

// MARK: - Variant B — "Sensor Focus" (moon icon · elapsed · metrics strip, no photo)

struct MonitorBLockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    private func statusWord() -> String {
        switch state.statusLabel {
        case "Sleeping":   return "Quiet"
        case "Monitoring": return "Active"
        case "Crying":     return "Crying"
        default:           return "Awake"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)

            // "Your baby is" + Kepler status
            VStack(alignment: .leading, spacing: 2) {
                Text("Your baby is")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(MB.olive)
                Text(statusWord())
                    .font(.custom("KeplerStd-Disp", size: 42))
                    .foregroundColor(MB.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.4), value: state.statusLabel)
            }

            Spacer(minLength: 10)

            // Full-width waveform — hero element
            LiveWaveformBars(
                soundLevel: state.soundLevel,
                barCount: 32, maxHeight: 36,
                barWidth: 3.5, spacing: 1.5,
                color: MB.clay
            )

            Spacer(minLength: 10)

            // Metrics strip — elapsed · battery · temp
            HStack(spacing: 14) {
                HStack(spacing: 3) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 10))
                        .foregroundColor(MB.olive)
                    Text(MB.formatElapsed(state.elapsedSeconds))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(MB.textSecondary)
                }
                HStack(spacing: 3) {
                    Image(systemName: state.isCharging ? "battery.100.bolt" : "battery.75")
                        .font(.system(size: 11))
                        .foregroundColor(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging))
                    Text("\(state.batteryLevel)%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(MB.textSecondary)
                }
                if let temp = state.temperature {
                    HStack(spacing: 3) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 10))
                            .foregroundColor(MB.olive)
                        Text("\(temp)°")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(MB.textSecondary)
                    }
                }
                Spacer()
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MB.apricot)
    }
}

// MARK: - Variant B — Dynamic Island: Compact

struct MonitorBCompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState
    var body: some View {
        Image(systemName: "moon.fill")
            .font(.system(size: 14))
            .foregroundColor(MB.statusColor(state.statusLabel))
            .padding(.leading, 4)
    }
}

struct MonitorBCompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState
    var body: some View {
        Text(MB.formatElapsed(state.elapsedSeconds))
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundColor(MB.clay)
            .padding(.trailing, 4)
    }
}

// MARK: - Variant B — Dynamic Island: Expanded

struct MonitorBExpandedLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer(minLength: 0)
            Text("Your baby is")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(MB.apricot)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
            Text(state.statusLabel == "Sleeping"   ? "Quiet"  :
                 state.statusLabel == "Monitoring" ? "Active" :
                 state.statusLabel == "Crying"     ? "Crying" : "Awake")
                .font(.custom("KeplerStd-Disp", size: 36))
                .foregroundColor(MB.clay)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.4), value: state.statusLabel)
            LiveWaveformBars(
                soundLevel: state.soundLevel,
                barCount: 12, maxHeight: 18,
                barWidth: 5, spacing: 2,
                color: MB.clay
            )
            Spacer(minLength: 0)
        }
        .padding(.leading, 8)
        .padding(.trailing, 4)
    }
}

/// Right region — metrics stack instead of photo
struct MonitorBExpandedTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Spacer(minLength: 0)
            // Elapsed
            HStack(spacing: 4) {
                Image(systemName: "moon.fill")
                    .font(.system(size: 10))
                    .foregroundColor(MB.olive)
                Text(MB.formatElapsed(state.elapsedSeconds))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(MB.apricot)
            }
            // Battery
            HStack(spacing: 4) {
                Image(systemName: state.isCharging ? "battery.100.bolt" : "battery.75")
                    .font(.system(size: 11))
                    .foregroundColor(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging))
                Text("\(state.batteryLevel)%")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(MB.apricot)
            }
            // Temp
            if let temp = state.temperature {
                HStack(spacing: 4) {
                    Image(systemName: "thermometer.medium")
                        .font(.system(size: 10))
                        .foregroundColor(MB.olive)
                    Text("\(temp)°")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(MB.apricot)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.trailing, 10)
        .padding(.leading, 4)
    }
}

// MARK: - Variant B — Dynamic Island: Minimal

struct MonitorBMinimal: View {
    let state: MoonboonActivityAttributes.ContentState
    var body: some View {
        Image(systemName: "moon.fill")
            .font(.system(size: 10))
            .foregroundColor(MB.statusColor(state.statusLabel))
    }
}

// MARK: - Dynamic Island: Bottom — play/stop cry audio (iOS 17+)
// Appears below the sensor pill only when baby is Crying.
// Tapping ToggleCryAudioIntent flips the App Group "isCryPlaying" flag;
// AppDelegate 300 ms timer picks it up and plays/stops crying_baby.mp3.

struct MonitorExpandedBottom: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        if state.statusLabel == "Crying" {
            if #available(iOS 17.0, *) {
                Button(intent: ToggleCryAudioIntent()) {
                    HStack(spacing: 8) {
                        Image(systemName: state.isPlayingCry ? "stop.fill" : "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text(state.isPlayingCry ? "Stop audio" : "Listen to baby")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(state.isPlayingCry ? MB.clay : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(state.isPlayingCry
                                  ? MB.clay.opacity(0.22)
                                  : Color.white.opacity(0.13))
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
    }
}

// MARK: - Shared sub-views

private struct MetricPill: View {
    let icon: String
    let value: String
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(MB.olive)
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(MB.surfaceWarm.opacity(0.75))
        }
    }
}

private struct BatteryPill: View {
    let level: Int
    let charging: Bool
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: charging ? "battery.100.bolt" : "battery.50")
                .font(.system(size: 11))
                .foregroundColor(MB.batteryColor(level: level, charging: charging))
            Text("\(level)%")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(MB.batteryColor(level: level, charging: charging))
        }
    }
}

private struct ElapsedPill: View {
    let seconds: Int
    var body: some View {
        Text(MB.formatElapsed(seconds))
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundColor(MB.surfaceWarm.opacity(0.5))
    }
}
