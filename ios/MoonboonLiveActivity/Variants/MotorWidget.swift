import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock Screen

struct MotorLockScreen: View {
    let attrs: MotorActivityAttributes
    let state: MotorActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 0) {
            // ── Row 1: name + running status ────────────────────────────────
            HStack {
                Image(systemName: "wind")
                    .font(.system(size: 13))
                    .foregroundColor(MB.clay)
                Text(attrs.motorName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(MB.surfaceWarm.opacity(0.7))
                Spacer()
                HStack(spacing: 5) {
                    Circle()
                        .fill(state.isRunning ? MB.clay : MB.olive.opacity(0.5))
                        .frame(width: 7, height: 7)
                    Text(state.isRunning ? "Running" : "Off")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(state.isRunning ? MB.surfaceWarm : MB.surfaceWarm.opacity(0.4))
                }
            }

            Spacer(minLength: 10)

            // ── Row 2: program name + speed dots ────────────────────────────
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(state.isRunning ? state.program : "—")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(state.isRunning ? MB.surfaceWarm : MB.surfaceWarm.opacity(0.3))
                    // Speed dots
                    HStack(spacing: 3) {
                        ForEach(1...10, id: \.self) { i in
                            Circle()
                                .fill(i <= state.speed && state.isRunning
                                      ? MB.clay
                                      : MB.surfaceWarm.opacity(0.15))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                Spacer()
                // Timer or battery
                VStack(alignment: .trailing, spacing: 4) {
                    if let rem = state.remainingSeconds, state.isRunning {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.system(size: 11))
                                .foregroundColor(MB.olive)
                            Text(formatTime(rem))
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(MB.surfaceWarm.opacity(0.8))
                        }
                    }
                    BatteryRow(level: state.batteryLevel, charging: state.isCharging)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(MB.darkBg)
    }

    private func formatTime(_ s: Int) -> String {
        let m = s / 60, sec = s % 60
        return String(format: "%d:%02d", m, sec)
    }
}

// MARK: - Dynamic Island: Compact

struct MotorCompactLeading: View {
    let state: MotorActivityAttributes.ContentState
    var body: some View {
        Image(systemName: "wind")
            .font(.system(size: 13))
            .foregroundColor(state.isRunning ? MB.clay : MB.olive.opacity(0.5))
            .padding(.leading, 4)
    }
}

struct MotorCompactTrailing: View {
    let state: MotorActivityAttributes.ContentState
    var body: some View {
        Text(state.isRunning ? state.program : "Off")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(state.isRunning ? MB.surfaceWarm : MB.surfaceWarm.opacity(0.4))
            .padding(.trailing, 4)
    }
}

// MARK: - Dynamic Island: Expanded

struct MotorExpanded: View {
    let attrs: MotorActivityAttributes
    let state: MotorActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 8) {
            // Top row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "wind")
                        .foregroundColor(MB.clay)
                    Text(attrs.motorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MB.surfaceWarm)
                }
                Spacer()
                HStack(spacing: 5) {
                    Circle()
                        .fill(state.isRunning ? MB.clay : MB.olive.opacity(0.4))
                        .frame(width: 7, height: 7)
                    Text(state.isRunning ? state.program : "Off")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(state.isRunning ? MB.clay : MB.surfaceWarm.opacity(0.4))
                }
            }

            // Speed dots full row
            HStack(spacing: 4) {
                ForEach(1...10, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i <= state.speed && state.isRunning
                              ? MB.clay.opacity(0.4 + Double(i) * 0.06)
                              : MB.surfaceWarm.opacity(0.1))
                        .frame(maxWidth: .infinity)
                        .frame(height: 8)
                }
            }

            // Bottom row: timer + battery
            HStack {
                if let rem = state.remainingSeconds, state.isRunning {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 10))
                            .foregroundColor(MB.olive)
                        Text(formatTime(rem))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(MB.surfaceWarm.opacity(0.8))
                    }
                }
                Spacer()
                BatteryRow(level: state.batteryLevel, charging: state.isCharging)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func formatTime(_ s: Int) -> String {
        let m = s / 60, sec = s % 60
        return String(format: "%d:%02d", m, sec)
    }
}

// MARK: - Dynamic Island: Minimal

struct MotorMinimal: View {
    let state: MotorActivityAttributes.ContentState
    var body: some View {
        Image(systemName: "wind")
            .font(.system(size: 11))
            .foregroundColor(state.isRunning ? MB.clay : MB.olive.opacity(0.4))
    }
}

// MARK: - Shared sub-view

private struct BatteryRow: View {
    let level: Int
    let charging: Bool
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: charging ? "battery.100.bolt" : "battery.50")
                .font(.system(size: 10))
                .foregroundColor(MB.batteryColor(level: level, charging: charging))
            Text("\(level)%")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(MB.batteryColor(level: level, charging: charging))
        }
    }
}
