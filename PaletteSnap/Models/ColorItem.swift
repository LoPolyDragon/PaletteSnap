import Foundation
import SwiftUI
import SwiftData

/// Represents a single color extracted from an image
@Model
final class ColorItem {
    var red: Double
    var green: Double
    var blue: Double
    var hue: Double
    var saturation: Double
    var lightness: Double
    var hexString: String
    var position: Int

    @Relationship(deleteRule: .nullify, inverse: \Palette.colors)
    var palette: Palette?

    init(red: Double, green: Double, blue: Double, position: Int = 0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.position = position

        // Calculate HSL values
        let hsl = ColorItem.rgbToHSL(r: red, g: green, b: blue)
        self.hue = hsl.h
        self.saturation = hsl.s
        self.lightness = hsl.l

        // Generate hex string
        self.hexString = String(format: "#%02X%02X%02X",
                                Int(red * 255),
                                Int(green * 255),
                                Int(blue * 255))
    }

    /// Convert RGB to HSL color space
    static func rgbToHSL(r: Double, g: Double, b: Double) -> (h: Double, s: Double, l: Double) {
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
        let delta = max - min

        var h: Double = 0
        var s: Double = 0
        let l: Double = (max + min) / 2

        if delta != 0 {
            s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min)

            switch max {
            case r:
                h = ((g - b) / delta) + (g < b ? 6 : 0)
            case g:
                h = ((b - r) / delta) + 2
            case b:
                h = ((r - g) / delta) + 4
            default:
                h = 0
            }

            h /= 6
        }

        return (h * 360, s, l)
    }

    /// Convert to SwiftUI Color
    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    /// RGB string representation
    var rgbString: String {
        "RGB(\(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255)))"
    }

    /// HSL string representation
    var hslString: String {
        "HSL(\(Int(hue))°, \(Int(saturation * 100))%, \(Int(lightness * 100))%)"
    }

    /// Check if color is light or dark for contrast purposes
    var isLight: Bool {
        // Using relative luminance calculation
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.5
    }
}
