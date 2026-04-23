import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock Screen

struct V2LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(attrs.babyName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(MB.textDark)
                Spacer()
                Text(state.statusLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(MB.statusColor(state.statusLabel))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(MB.statusColor(state.statusLabel).opacity(0.12))
                    .clipShape(Capsule())
            }

            HStack(spacing: 0) {
                V2MetricColumn(
                    icon: "waveform",
                    value: "\(Int(state.soundLevel * 100))%",
                    progress: state.soundLevel,
                    color: MB.clay
                )
                Divider().frame(height: 44).background(MB.olive.opacity(0.2))
                V2MetricColumn(
                    icon: "thermometer",
                    value: state.temperature.map { "\($0)°C" } ?? "—",
                    progress: state.temperature.map { Double($0) / 35.0 } ?? 0,
                    color: MB.olive
                )
                Divider().frame(height: 44).background(MB.olive.opacity(0.2))
                V2MetricColumn(
                    icon: state.isCharging ? "bolt.fill" : "battery.75percent",
                    value: "\(state.batteryLevel)%",
                    progress: Double(state.batteryLevel) / 100.0,
                    color: MB.batteryColor(level: state.batteryLevel, charging: state.isCharging)
                )
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(MB.surfaceWarm)
    }
}

private struct V2MetricColumn: View {
    let icon: String
    let value: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(MB.textDark)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.15))
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(min(progress, 1.0)), height: 3)
                }
            }
            .frame(height: 3)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Dynamic Island

struct V2CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "waveform")
                .font(.system(size: 12))
                .foregroundColor(MB.clay)
            Text("\(Int(state.soundLevel * 100))%")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.leading, 4)
    }
}

struct V2CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: state.isCharging ? "bolt.fill" : "battery.75percent")
                .font(.system(size: 11))
                .foregroundColor(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging))
            Text("\(state.batteryLevel)%")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.trailing, 4)
    }
}

struct V2Expanded: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(attrs.babyName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(state.statusLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(MB.statusColor(state.statusLabel))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(MB.statusColor(state.statusLabel).opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            HStack(spacing: 0) {
                V2MetricColumn(
                    icon: "waveform",
                    value: "\(Int(state.soundLevel * 100))%",
                    progress: state.soundLevel,
                    color: MB.clay
                )
                Divider().frame(height: 44).background(Color.white.opacity(0.15))
                V2MetricColumn(
                    icon: "thermometer",
                    value: state.temperature.map { "\($0)°C" } ?? "—",
                    progress: state.temperature.map { Double($0) / 35.0 } ?? 0,
                    color: MB.apricot
                )
                Divider().frame(height: 44).background(Color.white.opacity(0.15))
                V2MetricColumn(
                    icon: state.isCharging ? "bolt.fill" : "battery.75percent",
                    value: "\(state.batteryLevel)%",
                    progress: Double(state.batteryLevel) / 100.0,
                    color: MB.batteryColor(level: state.batteryLevel, charging: state.isCharging)
                )
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .background(Color.black)
    }
}

struct V2Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Image(systemName: "waveform")
            .font(.system(size: 12))
            .foregroundColor(MB.clay)
    }
}

// MARK: - Preview

#if canImport(WidgetKit) && !targetEnvironment(simulator)
#Preview("V2 Sleeping", as: .content, using: MoonboonActivityAttributes(babyName: "Emma", designVariant: 2)) {
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
        batteryLevel: 18, isCharging: true,
        statusLabel: "Crying", connectionState: "connected",
        wifiStrength: 0.5, elapsedSeconds: 120
    )
}
#endif
