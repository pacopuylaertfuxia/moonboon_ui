import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock Screen

struct V3LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(attrs.babyName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(MB.textDark)
                Spacer()
                Text(MB.formatElapsed(state.elapsedSeconds))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(MB.olive)
            }

            HStack(spacing: 4) {
                ForEach(0..<10, id: \.self) { i in
                    let h = eqBarHeight(index: i, level: state.soundLevel, count: 10)
                    VStack(spacing: 0) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 3)
                            .fill(LinearGradient(
                                colors: [MB.clay, MB.apricot],
                                startPoint: .bottom, endPoint: .top
                            ))
                            .frame(width: 6, height: h)
                    }
                }
            }
            .frame(height: 32)

            HStack {
                Text(state.statusLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(MB.statusColor(state.statusLabel))
                Spacer()
                if state.isMicMuted {
                    Image(systemName: "mic.slash")
                        .font(.system(size: 13))
                        .foregroundColor(MB.olive)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(MB.surfaceWarm)
    }
}

private func eqBarHeight(index: Int, level: Double, count: Int) -> CGFloat {
    let base: CGFloat = 4
    let maxH: CGFloat = 28
    let phase = Double(index) / Double(count) * .pi * 2
    let wave = (sin(phase + level * .pi * 2) + 1) / 2
    return base + CGFloat(wave * level) * (maxH - base)
}

// MARK: - Dynamic Island

struct V3CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                let h = eqBarHeight(index: i, level: state.soundLevel, count: 5)
                VStack(spacing: 0) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(MB.clay)
                        .frame(width: 3, height: max(3, h * 0.6))
                }
            }
        }
        .frame(height: 16)
        .padding(.leading, 4)
    }
}

struct V3CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        let initial = String(state.statusLabel.prefix(1))
        ZStack {
            Circle().fill(MB.statusColor(state.statusLabel).opacity(0.2))
            Text(initial)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(MB.statusColor(state.statusLabel))
        }
        .frame(width: 22, height: 22)
        .padding(.trailing, 4)
    }
}

struct V3Expanded: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<12, id: \.self) { i in
                    let h = eqBarHeight(index: i, level: state.soundLevel, count: 12)
                    VStack(spacing: 0) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 3)
                            .fill(LinearGradient(
                                colors: [MB.clay, MB.apricot],
                                startPoint: .bottom, endPoint: .top
                            ))
                            .frame(width: 6, height: max(4, h))
                    }
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 16)
            .padding(.top, 10)

            HStack {
                Text(attrs.babyName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text("·")
                    .foregroundColor(Color.white.opacity(0.4))
                Text(state.statusLabel)
                    .font(.system(size: 13))
                    .foregroundColor(MB.statusColor(state.statusLabel))
                Spacer()
                if let temp = state.temperature {
                    Text("\(temp)°")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(MB.apricot)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
    }
}

struct V3Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        let initial = String(state.statusLabel.prefix(1))
        Text(initial)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(MB.statusColor(state.statusLabel))
    }
}

// No previews — build and test on device
