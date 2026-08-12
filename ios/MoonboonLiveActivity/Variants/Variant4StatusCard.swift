import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock Screen

struct V4LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text(state.statusLabel)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(MB.statusColor(state.statusLabel))
                Text(attrs.babyName)
                    .font(.system(size: 13))
                    .foregroundColor(MB.olive)
            }
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().background(MB.olive.opacity(0.25)).padding(.horizontal, 16)

            HStack(spacing: 0) {
                V4MetricItem(icon: "moon.fill", value: MB.formatElapsed(state.elapsedSeconds))
                Divider().frame(height: 24).background(MB.olive.opacity(0.2))
                V4MetricItem(icon: "wifi", value: "\(Int(state.wifiStrength * 100))%")
                Divider().frame(height: 24).background(MB.olive.opacity(0.2))
                V4MetricItem(
                    icon: state.isCharging ? "bolt.fill" : "battery.75percent",
                    value: "\(state.batteryLevel)%",
                    color: MB.batteryColor(level: state.batteryLevel, charging: state.isCharging)
                )
            }
            .padding(.vertical, 10)
        }
        .background(MB.surfaceWarm)
    }
}

private struct V4MetricItem: View {
    let icon: String
    let value: String
    var color: Color = MB.olive

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(MB.textDark)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Dynamic Island

struct V4CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Text(state.statusLabel)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(MB.statusColor(state.statusLabel))
            .padding(.leading, 4)
    }
}

struct V4CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Text(MB.formatElapsed(state.elapsedSeconds))
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
            .padding(.trailing, 4)
    }
}

struct V4Expanded: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 6) {
            VStack(spacing: 2) {
                Text(state.statusLabel)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(MB.statusColor(state.statusLabel))
                Text(attrs.babyName)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            .padding(.top, 10)

            Divider().background(Color.white.opacity(0.15)).padding(.horizontal, 16)

            HStack(spacing: 0) {
                V4MetricItem(icon: "moon.fill", value: MB.formatElapsed(state.elapsedSeconds), color: MB.apricot)
                Divider().frame(height: 20).background(Color.white.opacity(0.15))
                V4MetricItem(icon: "wifi", value: "\(Int(state.wifiStrength * 100))%", color: MB.apricot)
                Divider().frame(height: 20).background(Color.white.opacity(0.15))
                V4MetricItem(
                    icon: state.isCharging ? "bolt.fill" : "battery.75percent",
                    value: "\(state.batteryLevel)%",
                    color: MB.batteryColor(level: state.batteryLevel, charging: state.isCharging)
                )
            }
            .padding(.bottom, 10)
        }
    }
}

struct V4Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        let initial = String(state.statusLabel.prefix(1))
        Text(initial)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(MB.statusColor(state.statusLabel))
    }
}

// No previews — build and test on device
