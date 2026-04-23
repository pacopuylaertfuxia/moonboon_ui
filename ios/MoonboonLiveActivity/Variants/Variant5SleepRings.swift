import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock Screen

struct V5LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                // Outer ring: battery
                Circle()
                    .stroke(MB.apricot.opacity(0.2), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: CGFloat(state.batteryLevel) / 100.0)
                    .stroke(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                // Inner ring: sound level
                Circle()
                    .stroke(MB.clay.opacity(0.15), lineWidth: 4)
                    .padding(10)
                Circle()
                    .trim(from: 0, to: CGFloat(state.soundLevel))
                    .stroke(MB.clay, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .padding(10)

                Image(systemName: "moon.fill")
                    .font(.system(size: 16))
                    .foregroundColor(MB.olive)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 5) {
                Text(attrs.babyName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(MB.textDark)
                Text(state.statusLabel)
                    .font(.system(size: 13))
                    .foregroundColor(MB.statusColor(state.statusLabel))
                if let temp = state.temperature {
                    HStack(spacing: 4) {
                        Image(systemName: "thermometer")
                            .font(.system(size: 11))
                        Text("\(temp)°C")
                            .font(.system(size: 12, design: .monospaced))
                    }
                    .foregroundColor(MB.olive)
                }
                if state.isCharging {
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                        Text("Charging")
                            .font(.system(size: 11))
                            .foregroundColor(MB.olive)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(MB.surfaceWarm)
    }
}

// MARK: - Dynamic Island

struct V5CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: CGFloat(state.soundLevel))
                .stroke(MB.clay, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 18, height: 18)
            Circle()
                .stroke(MB.clay.opacity(0.15), lineWidth: 3)
                .frame(width: 18, height: 18)
        }
        .padding(.leading, 4)
    }
}

struct V5CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        let display = state.temperature.map { "\($0)°" } ?? "\(state.batteryLevel)%"
        Text(display)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
            .padding(.trailing, 4)
    }
}

struct V5Expanded: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(MB.apricot.opacity(0.2), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: CGFloat(state.batteryLevel) / 100.0)
                    .stroke(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Circle()
                    .stroke(MB.clay.opacity(0.15), lineWidth: 5)
                    .padding(14)
                Circle()
                    .trim(from: 0, to: CGFloat(state.soundLevel))
                    .stroke(MB.clay, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .padding(14)

                Image(systemName: "moon.fill")
                    .font(.system(size: 18))
                    .foregroundColor(MB.apricot)
            }
            .frame(width: 80, height: 80)
            .padding(.leading, 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(attrs.babyName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(state.statusLabel)
                    .font(.system(size: 13))
                    .foregroundColor(MB.statusColor(state.statusLabel))
                if let temp = state.temperature {
                    Text("\(temp)°C")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(MB.apricot)
                }
                Text(MB.formatElapsed(state.elapsedSeconds))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(MB.apricot.opacity(0.7))
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct V5Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: CGFloat(state.soundLevel))
                .stroke(MB.clay, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 16, height: 16)
            Circle()
                .stroke(MB.clay.opacity(0.15), lineWidth: 3)
                .frame(width: 16, height: 16)
        }
    }
}

// MARK: - Preview

#if canImport(WidgetKit) && !targetEnvironment(simulator)
#Preview("V5 Sleeping", as: .content, using: MoonboonActivityAttributes(babyName: "Emma", designVariant: 5)) {
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
        batteryLevel: 60, isCharging: true,
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
