import Foundation
import SwiftUI
import SwiftData

/// Represents a saved color palette extracted from an image
@Model
final class Palette {
    var id: UUID
    var name: String
    var createdAt: Date
    var imageData: Data?

    @Relationship(deleteRule: .cascade)
    var colors: [ColorItem]

    @Relationship(deleteRule: .nullify)
    var folder: PaletteFolder?

    init(name: String, colors: [ColorItem] = [], imageData: Data? = nil, folder: PaletteFolder? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.colors = colors
        self.imageData = imageData
        self.folder = folder
    }

    /// Get thumbnail image from stored data
    var thumbnailImage: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }

    /// Get sorted colors by position
    var sortedColors: [ColorItem] {
        colors.sorted { $0.position < $1.position }
    }

    /// Get primary color (first color in palette)
    var primaryColor: Color {
        sortedColors.first?.color ?? .gray
    }

    /// Generate a gradient from all colors
    var gradient: LinearGradient {
        let gradientColors = sortedColors.map { $0.color }
        return LinearGradient(
            colors: gradientColors.isEmpty ? [.gray] : gradientColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Format created date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}
