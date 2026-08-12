import SwiftUI
import WidgetKit

// MARK: - Waveform strip (static pattern, clay bars)

private struct V11WaveformStrip: View {
    let soundLevel: Double

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
                    .fill(MB.clay.opacity(0.7 + soundLevel * 0.3))
                    .frame(width: 2, height: min(scaled, 14))
                    .animation(
                        .interpolatingSpring(stiffness: 160, damping: 16)
                            .delay(Double(i) * 0.008),
                        value: soundLevel
                    )
            }
        }
    }
}

// MARK: - Camera rings (concentric circles + live dot)

private struct V11CameraRings: View {
    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(MB.clay.opacity(0.18), lineWidth: 1)
                .frame(width: 66, height: 66)
            // Middle ring
            Circle()
                .stroke(MB.clay.opacity(0.32), lineWidth: 1)
                .frame(width: 56, height: 56)
            // Inner ring
            Circle()
                .stroke(MB.clay.opacity(0.5), lineWidth: 1)
                .frame(width: 46, height: 46)
            // Camera lens background
            Circle()
                .fill(Color.black.opacity(0.80))
                .frame(width: 40, height: 40)
            // Camera image
            Image("camera_device")
                .resizable()
                .scaledToFill()
                .frame(width: 38, height: 38)
                .clipShape(Circle())
                .opacity(0.9)
            // Live indicator dot
            Circle()
                .fill(Color.green)
                .frame(width: 9, height: 9)
                .overlay(Circle().stroke(MB.apricot, lineWidth: 1.5))
                .offset(x: -13, y: 14)
        }
        .frame(width: 66, height: 66)
    }
}

// MARK: - Lock Screen

struct V11LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            // Left: Camera rings
            V11CameraRings()
                .padding(.leading, 10)

            // Center: moonboon wordmark + waveform
            VStack(alignment: .leading, spacing: 5) {
                Text("moonboon")
                    .font(Font.custom("Kepler-Std-Display", size: 32))
                    .foregroundColor(MB.textDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                V11WaveformStrip(soundLevel: state.soundLevel)
                    .frame(height: 14)
            }
            .padding(.leading, 14)

            Spacer()

            // Right: Baby face illustration
            Image("baby")
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 44)
                .padding(.trailing, 18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 86)
        .background(MB.apricot)
    }
}

// MARK: - Dynamic Island — Compact

struct V11CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.green)
                .frame(width: 7, height: 7)
            Text("moonboon")
                .font(Font.custom("Kepler-Std-Display", size: 13))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.leading, 4)
    }
}

struct V11CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    private let pattern: [CGFloat] = [4, 8, 5, 10, 6, 8, 4]

    var body: some View {
        HStack(alignment: .center, spacing: 1.5) {
            ForEach(pattern.indices, id: \.self) { i in
                let h = pattern[i] * CGFloat(0.5 + state.soundLevel * 1.0)
                RoundedRectangle(cornerRadius: 1)
                    .fill(MB.clay)
                    .frame(width: 2, height: min(h, 12))
            }
        }
        .frame(height: 14)
        .padding(.trailing, 4)
    }
}

// MARK: - Dynamic Island — Expanded

struct V11ExpandedLeading: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 10) {
            V11CameraRings()
                .scaleEffect(0.55)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 1) {
                Text("moonboon")
                    .font(Font.custom("Kepler-Std-Display", size: 16))
                    .foregroundColor(.white)
                Text(state.statusLabel)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(MB.clay)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: state.statusLabel)
            }
        }
        .padding(.leading, 6)
    }
}

struct V11ExpandedTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        V11WaveformStrip(soundLevel: state.soundLevel)
            .frame(width: 80, height: 20)
            .padding(.trailing, 6)
    }
}

// MARK: - Dynamic Island — Minimal

struct V11Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        Circle()
            .fill(MB.clay)
            .frame(width: 10, height: 10)
    }
}
