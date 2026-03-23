import Foundation
import SwiftUI
import SwiftData

/// Represents a folder for organizing palettes
@Model
final class PaletteFolder {
    var id: UUID
    var name: String
    var createdAt: Date
    var colorHex: String

    @Relationship(deleteRule: .nullify, inverse: \Palette.folder)
    var palettes: [Palette]?

    init(name: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.colorHex = colorHex
        self.palettes = []
    }

    /// Convert hex string to SwiftUI Color
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    /// Count of palettes in this folder
    var paletteCount: Int {
        palettes?.count ?? 0
    }
}
