import SwiftUI
import WidgetKit

// ── App Group image helper ────────────────────────────────────────────────────

private let kV9AppGroup  = "group.com.moonboon.moonboonUi"
private let kV9FrameFile = "live_feed_frame.jpg"

private func v9CachedFrame() -> UIImage? {
    guard let url = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: kV9AppGroup)?
        .appendingPathComponent(kV9FrameFile),
          let data = try? Data(contentsOf: url)
    else { return nil }
    return UIImage(data: data)
}

// ── Status helpers ────────────────────────────────────────────────────────────

private func v9StatusText(_ label: String) -> String {
    switch label {
    case "Sleeping":   return "Quiet"
    case "Monitoring": return "Active"
    case "Crying":     return "Crying"
    default:           return label
    }
}

// ── Gradient waveform bars (clay → olive) ─────────────────────────────────────

private struct V9GradientBars: View {
    let soundLevel: Double
    let barCount: Int
    let maxHeight: CGFloat

    private let gradient = LinearGradient(
        colors: [MB.clay, MB.olive],
        startPoint: .top,
        endPoint: .bottom
    )
    private let personality: [Double] = [0.45, 0.85, 1.0, 0.65]

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<barCount, id: \.self) { i in
                let p = personality[i % personality.count]
                let floor: CGFloat = 3.0
                let h = floor + CGFloat(max(soundLevel, 0.18) * p) * (maxHeight - floor)
                RoundedRectangle(cornerRadius: 2)
                    .fill(gradient)
                    .frame(width: 4, height: h)
                    .animation(
                        .interpolatingSpring(stiffness: 180, damping: 14)
                            .delay(Double(i) * 0.04),
                        value: soundLevel
                    )
            }
        }
        .frame(height: maxHeight)
    }
}

// ── Warm waveform strip (many tiny bars, clay) ────────────────────────────────

private struct V9WaveformStrip: View {
    let soundLevel: Double

    // Static height pattern — alternating short/tall for waveform fingerprint look
    private let pattern: [CGFloat] = [
        3, 5, 3, 7, 3, 5, 9, 5, 3, 7, 3, 5, 3, 9, 5, 3, 7, 5, 3, 5,
        7, 3, 5, 9, 3, 5, 7, 3, 5, 3, 7, 5, 9, 3, 5, 7, 3, 5, 3, 5,
    ]

    var body: some View {
        HStack(alignment: .center, spacing: 1.5) {
            ForEach(pattern.indices, id: \.self) { i in
                let base = pattern[i]
                let scaled = base * CGFloat(0.5 + soundLevel * 1.0)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(MB.clay.opacity(0.6 + soundLevel * 0.4))
                    .frame(width: 2, height: min(scaled, 18))
                    .animation(
                        .interpolatingSpring(stiffness: 160, damping: 16)
                            .delay(Double(i) * 0.008),
                        value: soundLevel
                    )
            }
        }
    }
}

// ── Overlay card background ───────────────────────────────────────────────────

private struct V9Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(MB.apricot.opacity(0.55))
            )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPACT — Leading: moon icon (clay)
// ─────────────────────────────────────────────────────────────────────────────

struct V9CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Image(systemName: "moon.fill")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(MB.clay)
            .padding(.leading, 4)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPACT — Trailing: 4 gradient bars
// ─────────────────────────────────────────────────────────────────────────────

struct V9CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        V9GradientBars(soundLevel: state.soundLevel, barCount: 4, maxHeight: 14)
            .padding(.trailing, 4)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDED — Leading: moon + "Status / Quiet" + waveform
// ─────────────────────────────────────────────────────────────────────────────

struct V9ExpandedLeading: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "moon.fill")
                .font(.system(size: 14))
                .foregroundColor(MB.clay)

            VStack(alignment: .leading, spacing: 1) {
                Text("Status")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(MB.clay)
                Text(v9StatusText(state.statusLabel))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(MB.olive)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.35), value: state.statusLabel)
            }

            V9WaveformStrip(soundLevel: state.soundLevel)
                .frame(maxWidth: .infinity)
        }
        .padding(.leading, 6)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDED — Trailing: mode info
// ─────────────────────────────────────────────────────────────────────────────

struct V9ExpandedTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text("Mode")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(MB.clay)
            Text(state.monitorMode.isEmpty ? "Standard" : state.monitorMode)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(MB.olive)
        }
        .padding(.trailing, 6)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MINIMAL
// ─────────────────────────────────────────────────────────────────────────────

struct V9Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Image(systemName: "moon.fill")
            .font(.system(size: 10))
            .foregroundColor(MB.clay)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCK SCREEN — Warm layered design
// ─────────────────────────────────────────────────────────────────────────────

struct V9LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 8) {

            // ── Status + waveform card ────────────────────────────────────────
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Status")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(MB.clay)
                    Text(v9StatusText(state.statusLabel))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(MB.olive)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.35), value: state.statusLabel)
                }
                Spacer()
                V9WaveformStrip(soundLevel: state.soundLevel)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 18).fill(MB.apricot.opacity(0.55)))

            // ── Baby photo (if available) ─────────────────────────────────────
            if let img = v9CachedFrame() {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 140)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            // ── Bottom stat cards ─────────────────────────────────────────────
            HStack(spacing: 8) {
                // Sounds card
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(state.soundLevel > 0.5 ? "Sounds" : "Sound")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(MB.clay)
                        Text(state.soundLevel > 0.5 ? "Detected" : "Quiet")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(MB.olive)
                            .contentTransition(.opacity)
                            .animation(.easeInOut(duration: 0.35), value: state.statusLabel)
                    }
                    Spacer()
                    Text("\(max(1, state.elapsedSeconds / 60))")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundColor(MB.olive)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 18).fill(MB.apricot.opacity(0.55)))

                // Mode card
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Mode")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(MB.clay)
                        Text(state.monitorMode.isEmpty ? "Standard" : state.monitorMode)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(MB.olive)
                    }
                    Spacer()
                    // Bell icon in rounded square
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(MB.apricot)
                            .frame(width: 36, height: 36)
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14))
                            .foregroundColor(MB.olive)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 18).fill(MB.apricot.opacity(0.55)))
            }
        }
        .padding(12)
        .background(MB.creme)
    }
}
