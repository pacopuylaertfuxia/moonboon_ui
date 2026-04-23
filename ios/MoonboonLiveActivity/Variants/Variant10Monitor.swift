import SwiftUI
import WidgetKit

// ── Status helper ─────────────────────────────────────────────────────────────

private func v10StatusText(_ label: String) -> String {
    label == "Crying" ? "Crying" : "Quiet"
}

private func v10IsCrying(_ label: String) -> Bool {
    label == "Crying"
}

// ── 4-bar gradient bars ───────────────────────────────────────────────────────

private struct V10Bars: View {
    let soundLevel: Double

    private let peakHeights: [CGFloat] = [7, 13, 17, 9]
    private let minH: CGFloat = 5
    private let gradient = LinearGradient(
        colors: [MB.clay, MB.olive],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<4, id: \.self) { i in
                let h = minH + (peakHeights[i] - minH) * CGFloat(soundLevel)
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(gradient)
                    .frame(width: 5, height: h)
                    .animation(
                        .interpolatingSpring(stiffness: 200, damping: 15)
                            .delay(Double(i) * 0.03),
                        value: soundLevel
                    )
            }
        }
    }
}

// ── Baby photo ────────────────────────────────────────────────────────────────

private struct V10Photo: View {
    let isCrying: Bool
    var size: CGFloat = 105

    var body: some View {
        Group {
            if let img = UIImage(named: isCrying ? "crying" : "quiet") {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(hex: "#D9D9D9")
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.242))
    }
}

// ── Moon logo ─────────────────────────────────────────────────────────────────

private struct V10Moon: View {
    var size: CGFloat = 22
    var tint: Color = .white

    var body: some View {
        if let img = UIImage(named: "logo") {
            Image(uiImage: img)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(tint)
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: "moon.fill")
                .font(.system(size: size))
                .foregroundColor(tint)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPACT — Leading: moon logo
// ─────────────────────────────────────────────────────────────────────────────

struct V10CompactLeading: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Moonboon camera device image, circular crop
            Group {
                if let img = UIImage(named: "camera_device") {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle().fill(Color.gray.opacity(0.4))
                }
            }
            .frame(width: 26, height: 26)
            .clipShape(Circle())

            // Green live dot
            Circle()
                .fill(Color(red: 0.2, green: 0.78, blue: 0.35))
                .frame(width: 7, height: 7)
                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                .offset(x: 1, y: 1)
        }
        .padding(.leading, 4)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPACT — Trailing: 4 gradient bars
// ─────────────────────────────────────────────────────────────────────────────

struct V10CompactTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        V10Bars(soundLevel: state.soundLevel)
            .padding(.trailing, 4)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDED — Leading: moon logo above "[name] is" + status (KeplerStd)
// ─────────────────────────────────────────────────────────────────────────────

struct V10ExpandedLeading: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            V10Moon(size: 22, tint: .white)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(attrs.babyName) is")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "#E5D5C5"))

                Text(v10StatusText(state.statusLabel))
                    .font(Font.custom("KeplerStd-Disp", size: 38))
                    .foregroundColor(MB.clay)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.35), value: state.statusLabel)
            }
        }
        .padding(.leading, 14)
        .padding(.vertical, 16)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDED — Center: 4 bars (centred in the island)
// ─────────────────────────────────────────────────────────────────────────────

struct V10ExpandedCenter: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        V10Bars(soundLevel: state.soundLevel)
            .frame(maxHeight: .infinity, alignment: .center)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDED — Trailing: baby photo only
// ─────────────────────────────────────────────────────────────────────────────

struct V10ExpandedTrailing: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        V10Photo(isCrying: v10IsCrying(state.statusLabel), size: 105)
            .padding(.trailing, 10)
            .frame(maxHeight: .infinity, alignment: .center)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MINIMAL
// ─────────────────────────────────────────────────────────────────────────────

struct V10Minimal: View {
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        V10Moon(size: 10, tint: MB.clay)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCK SCREEN — warm apricot bg
// ─────────────────────────────────────────────────────────────────────────────

struct V10LockScreen: View {
    let attrs: MoonboonActivityAttributes
    let state: MoonboonActivityAttributes.ContentState

    var body: some View {
        HStack(alignment: .center, spacing: 0) {

            VStack(alignment: .leading, spacing: 9) {
                V10Moon(size: 22, tint: MB.olive)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(attrs.babyName) is")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(MB.olive)

                    Text(v10StatusText(state.statusLabel))
                        .font(Font.custom("KeplerStd-Disp", size: 38))
                        .foregroundColor(MB.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.35), value: state.statusLabel)
                }
            }

            Spacer()

            V10Bars(soundLevel: state.soundLevel)

            Spacer()

            V10Photo(isCrying: v10IsCrying(state.statusLabel), size: 120)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(MB.apricot)
    }
}
