import SwiftUI

extension Color {
    /// Initialize Color from hex string
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let length = hexSanitized.count
        let r, g, b, a: Double

        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }

    /// Convert Color to hex string
    var hexString: String? {
        guard let components = UIColor(self).cgColor.components else {
            return nil
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]

        return String(format: "#%02X%02X%02X",
                      Int(r * 255),
                      Int(g * 255),
                      Int(b * 255))
    }

    /// Get contrasting color (black or white) for text on this background
    var contrastingTextColor: Color {
        guard let components = UIColor(self).cgColor.components,
              components.count >= 3 else {
            return .primary
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]

        // Calculate relative luminance
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b

        return luminance > 0.5 ? .black : .white
    }

    /// Create a lighter version of this color
    func lighter(by amount: Double = 0.2) -> Color {
        return adjust(by: abs(amount))
    }

    /// Create a darker version of this color
    func darker(by amount: Double = 0.2) -> Color {
        return adjust(by: -abs(amount))
    }

    private func adjust(by amount: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return Color(
            red: min(max(red + amount, 0), 1),
            green: min(max(green + amount, 0), 1),
            blue: min(max(blue + amount, 0), 1),
            opacity: Double(alpha)
        )
    }
}
