import Foundation
import SwiftUI

/// Service for generating color harmonies based on color theory
final class ColorHarmonyService {
    static let shared = ColorHarmonyService()

    private init() {}

    /// Generate complementary color (opposite on color wheel)
    func complementary(for color: ColorItem) -> ColorItem {
        let newHue = (color.hue + 180).truncatingRemainder(dividingBy: 360)
        return createColorItem(hue: newHue, saturation: color.saturation, lightness: color.lightness)
    }

    /// Generate analogous colors (adjacent on color wheel)
    func analogous(for color: ColorItem) -> [ColorItem] {
        let offset: Double = 30
        let hue1 = (color.hue - offset).truncatingRemainder(dividingBy: 360)
        let hue2 = (color.hue + offset).truncatingRemainder(dividingBy: 360)

        return [
            createColorItem(hue: hue1, saturation: color.saturation, lightness: color.lightness),
            createColorItem(hue: hue2, saturation: color.saturation, lightness: color.lightness)
        ]
    }

    /// Generate triadic colors (120° apart on color wheel)
    func triadic(for color: ColorItem) -> [ColorItem] {
        let hue1 = (color.hue + 120).truncatingRemainder(dividingBy: 360)
        let hue2 = (color.hue + 240).truncatingRemainder(dividingBy: 360)

        return [
            createColorItem(hue: hue1, saturation: color.saturation, lightness: color.lightness),
            createColorItem(hue: hue2, saturation: color.saturation, lightness: color.lightness)
        ]
    }

    /// Generate split complementary colors
    func splitComplementary(for color: ColorItem) -> [ColorItem] {
        let complementaryHue = (color.hue + 180).truncatingRemainder(dividingBy: 360)
        let offset: Double = 30

        let hue1 = (complementaryHue - offset).truncatingRemainder(dividingBy: 360)
        let hue2 = (complementaryHue + offset).truncatingRemainder(dividingBy: 360)

        return [
            createColorItem(hue: hue1, saturation: color.saturation, lightness: color.lightness),
            createColorItem(hue: hue2, saturation: color.saturation, lightness: color.lightness)
        ]
    }

    /// Generate tetradic colors (square on color wheel)
    func tetradic(for color: ColorItem) -> [ColorItem] {
        let hue1 = (color.hue + 90).truncatingRemainder(dividingBy: 360)
        let hue2 = (color.hue + 180).truncatingRemainder(dividingBy: 360)
        let hue3 = (color.hue + 270).truncatingRemainder(dividingBy: 360)

        return [
            createColorItem(hue: hue1, saturation: color.saturation, lightness: color.lightness),
            createColorItem(hue: hue2, saturation: color.saturation, lightness: color.lightness),
            createColorItem(hue: hue3, saturation: color.saturation, lightness: color.lightness)
        ]
    }

    /// Generate monochromatic colors (same hue, different lightness)
    func monochromatic(for color: ColorItem, count: Int = 5) -> [ColorItem] {
        var colors: [ColorItem] = []

        for i in 0..<count {
            let lightnessFactor = Double(i) / Double(count - 1)
            let newLightness = 0.2 + (lightnessFactor * 0.6) // Range from 0.2 to 0.8

            colors.append(createColorItem(
                hue: color.hue,
                saturation: color.saturation,
                lightness: newLightness
            ))
        }

        return colors
    }

    /// Generate shades (darker versions)
    func shades(for color: ColorItem, count: Int = 5) -> [ColorItem] {
        var colors: [ColorItem] = []

        for i in 0..<count {
            let factor = Double(i) / Double(count - 1)
            let newLightness = color.lightness * (1.0 - factor * 0.8) // Darken by up to 80%

            colors.append(createColorItem(
                hue: color.hue,
                saturation: color.saturation,
                lightness: max(0.0, newLightness)
            ))
        }

        return colors
    }

    /// Generate tints (lighter versions)
    func tints(for color: ColorItem, count: Int = 5) -> [ColorItem] {
        var colors: [ColorItem] = []

        for i in 0..<count {
            let factor = Double(i) / Double(count - 1)
            let newLightness = color.lightness + ((1.0 - color.lightness) * factor)

            colors.append(createColorItem(
                hue: color.hue,
                saturation: color.saturation,
                lightness: min(1.0, newLightness)
            ))
        }

        return colors
    }

    // MARK: - Private Helpers

    private func createColorItem(hue: Double, saturation: Double, lightness: Double) -> ColorItem {
        let rgb = hslToRGB(h: hue, s: saturation, l: lightness)
        return ColorItem(red: rgb.r, green: rgb.g, blue: rgb.b)
    }

    private func hslToRGB(h: Double, s: Double, l: Double) -> (r: Double, g: Double, b: Double) {
        let c = (1 - abs(2 * l - 1)) * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - c / 2

        var r: Double = 0
        var g: Double = 0
        var b: Double = 0

        let hueSegment = Int(h / 60)

        switch hueSegment {
        case 0:
            r = c; g = x; b = 0
        case 1:
            r = x; g = c; b = 0
        case 2:
            r = 0; g = c; b = x
        case 3:
            r = 0; g = x; b = c
        case 4:
            r = x; g = 0; b = c
        case 5:
            r = c; g = 0; b = x
        default:
            r = c; g = x; b = 0
        }

        return (r + m, g + m, b + m)
    }
}

// MARK: - Harmony Type

enum HarmonyType: String, CaseIterable, Identifiable {
    case complementary = "Complementary"
    case analogous = "Analogous"
    case triadic = "Triadic"
    case splitComplementary = "Split Complementary"
    case tetradic = "Tetradic"
    case monochromatic = "Monochromatic"
    case shades = "Shades"
    case tints = "Tints"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .complementary:
            return "Colors opposite on the color wheel"
        case .analogous:
            return "Colors adjacent on the color wheel"
        case .triadic:
            return "Three colors evenly spaced on the color wheel"
        case .splitComplementary:
            return "Base color plus two colors adjacent to its complement"
        case .tetradic:
            return "Four colors evenly spaced on the color wheel"
        case .monochromatic:
            return "Variations in lightness of a single hue"
        case .shades:
            return "Darker variations of the color"
        case .tints:
            return "Lighter variations of the color"
        }
    }

    var iconName: String {
        switch self {
        case .complementary:
            return "circle.lefthalf.filled"
        case .analogous:
            return "arrow.left.and.right"
        case .triadic:
            return "triangle"
        case .splitComplementary:
            return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        case .tetradic:
            return "square"
        case .monochromatic:
            return "circle.grid.cross"
        case .shades:
            return "moon.fill"
        case .tints:
            return "sun.max.fill"
        }
    }
}
