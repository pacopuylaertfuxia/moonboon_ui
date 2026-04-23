import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock Screen

struct V1LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(MB.statusColor(state.statusLabel))
                .frame(width: 10, height: 10)
            Text(attrs.babyName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(MB.textDark)
            Rectangle()
                .fill(MB.olive.opacity(0.3))
                .frame(width: 1, height: 14)
            Text(state.statusLabel)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(MB.olive)
            Spacer()
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { i in
                    let height = soundBarHeight(index: i, level: state.soundLevel, bars: 5)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(MB.clay)
                        .frame(width: 4, height: height)
                }
            }
            .frame(height: 20)
            if state.isMicMuted {
                Image(systemName: "mic.slash.fill")
                    .font(.system(size: 13))
                    .foregroundColor(MB.olive)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(MB.surfaceWarm)
    }
}

// MARK: - Dynamic Island

struct V1CompactLeading: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(MB.statusColor(state.statusLabel)).frame(width: 8, height: 8)
            Text(attrs.babyName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.leading, 4)
    }
}

struct V1CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Text("\(state.batteryLevel)%")
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundColor(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging))
            .padding(.trailing, 4)
    }
}

struct V1Expanded: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(attrs.babyName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(state.statusLabel)
                    .font(.system(size: 13))
                    .foregroundColor(MB.statusColor(state.statusLabel))
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            HStack(spacing: 4) {
                ForEach(0..<8, id: \.self) { i in
                    let h = soundBarHeight(index: i, level: state.soundLevel, bars: 8)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(MB.clay)
                        .frame(width: 5, height: h)
                }
            }
            .frame(height: 28)
            .padding(.horizontal, 16)
            .padding(.top, 10)

            Divider().background(Color.white.opacity(0.15)).padding(.horizontal, 16).padding(.top, 10)

            HStack {
                Label("\(state.batteryLevel)%", systemImage: state.isCharging ? "bolt.fill" : "battery.75percent")
                    .font(.system(size: 12))
                    .foregroundColor(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging))
                Spacer()
                if let temp = state.temperature {
                    Label("\(temp)°C", systemImage: "thermometer")
                        .font(.system(size: 12))
                        .foregroundColor(MB.apricot)
                }
                Spacer()
                Text(MB.formatElapsed(state.elapsedSeconds))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(MB.apricot)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

struct V1Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Circle().fill(MB.statusColor(state.statusLabel)).frame(width: 12, height: 12)
    }
}

// MARK: - Helpers

func soundBarHeight(index: Int, level: Double, bars: Int) -> CGFloat {
    let base: CGFloat = 4
    let maxAdd: CGFloat = 16
    let sine = abs(sin(Double(index) * 0.8 + level * 3.0))
    return base + CGFloat(sine * level) * maxAdd
}

// MARK: - Preview

#if canImport(WidgetKit) && !targetEnvironment(simulator)
#Preview("V1 Sleeping", as: .content, using: MoonboonActivityAttributes(babyName: "Emma", designVariant: 1)) {
    MoonboonLiveActivityWidget()
} contentStates: {
    MoonboonActivityAttributes.ContentState(
        soundLevel: 0.1, isMicMuted: false, temperature: 20,
        batteryLevel: 85, isCharging: false,
        statusLabel: "Sleeping", connectionState: "connected",
        wifiStrength: 0.9, elapsedSeconds: 3900
    )
    MoonboonActivityAttributes.ContentState(
        soundLevel: 0.5, isMicMuted: false, temperature: 22,
        batteryLevel: 60, isCharging: false,
        statusLabel: "Awake", connectionState: "connected",
        wifiStrength: 0.7, elapsedSeconds: 600
    )
    MoonboonActivityAttributes.ContentState(
        soundLevel: 0.9, isMicMuted: false, temperature: 23,
        batteryLevel: 18, isCharging: false,
        statusLabel: "Crying", connectionState: "connected",
        wifiStrength: 0.5, elapsedSeconds: 120
    )
}
#endif
