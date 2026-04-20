import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock Screen

struct V6LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "moon.fill")
                    .font(.system(size: 14))
                    .foregroundColor(MB.clay)
                Text(attrs.babyName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(MB.clay)
                Spacer()
                Text(state.statusLabel)
                    .font(.system(size: 13))
                    .foregroundColor(MB.creme)
            }

            HStack(spacing: 4) {
                ForEach(0..<8, id: \.self) { i in
                    let h = soundBarHeight(index: i, level: state.soundLevel, bars: 8)
                    VStack(spacing: 0) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient(
                                colors: [MB.clay, MB.apricot],
                                startPoint: .bottom, endPoint: .top
                            ))
                            .frame(width: 6, height: h)
                    }
                }
            }
            .frame(height: 24)

            HStack {
                if let temp = state.temperature {
                    Label("\(temp)°C", systemImage: "thermometer")
                        .font(.system(size: 11))
                        .foregroundColor(MB.apricot)
                }
                Spacer()
                Label("\(state.batteryLevel)%",
                      systemImage: state.isCharging ? "bolt.fill" : "battery.75percent")
                    .font(.system(size: 11))
                    .foregroundColor(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(MB.darkBg)
    }
}

// MARK: - Dynamic Island

struct V6CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Image(systemName: "moon.fill")
            .font(.system(size: 13))
            .foregroundColor(MB.clay)
            .padding(.leading, 4)
    }
}

struct V6CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Text(state.statusLabel)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(MB.creme)
            .padding(.trailing, 4)
    }
}

struct V6Expanded: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 14))
                        .foregroundColor(MB.clay)
                    Text(attrs.babyName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MB.creme)
                }
                Spacer()
                Text(state.statusLabel)
                    .font(.system(size: 13))
                    .foregroundColor(MB.statusColor(state.statusLabel))
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)

            Rectangle()
                .fill(MB.clay)
                .frame(height: 1)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            HStack {
                if let temp = state.temperature {
                    Label("\(temp)°C", systemImage: "thermometer")
                        .font(.system(size: 11))
                        .foregroundColor(MB.apricot)
                }
                Spacer()
                Label(MB.formatElapsed(state.elapsedSeconds), systemImage: "clock")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(MB.apricot)
                Spacer()
                Label("\(state.batteryLevel)%",
                      systemImage: state.isCharging ? "bolt.fill" : "battery.75percent")
                    .font(.system(size: 11))
                    .foregroundColor(MB.batteryColor(level: state.batteryLevel, charging: state.isCharging))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(MB.darkBg)
    }
}

struct V6Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Image(systemName: "moon.fill")
            .font(.system(size: 13))
            .foregroundColor(MB.clay)
    }
}

// No previews — build and test on device
