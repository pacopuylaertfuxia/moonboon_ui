import SwiftUI

enum MB {
    static let clay          = Color(hex: "#B59E85")
    static let olive         = Color(hex: "#70695F")
    static let textDark      = Color(hex: "#1A1008")
    static let textSecondary = Color(hex: "#464545")  // text/secondary — used on cream bg
    static let surfaceWarm   = Color(hex: "#F5F3F1")
    static let creme         = Color(hex: "#F1E8DE")
    static let apricot       = Color(hex: "#E5D5C5")
    static let darkBg        = Color(hex: "#0F0D0B")

    static func statusColor(_ label: String) -> Color {
        switch label {
        case "Sleeping": return MB.olive
        case "Awake":    return MB.clay
        case "Crying":   return Color.red
        default:         return MB.clay
        }
    }

    static func batteryColor(level: Int, charging: Bool) -> Color {
        if charging   { return Color.green }
        if level < 20 { return Color.red }
        return MB.clay
    }

    static func formatElapsed(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
