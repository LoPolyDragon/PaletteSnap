import UIKit
import SwiftUI

/// Service for generating beautiful palette card images for export
final class ImageExportService {
    static let shared = ImageExportService()

    private init() {}

    /// Generate a shareable palette card image
    /// - Parameters:
    ///   - palette: The palette to export
    ///   - size: Size of the output image
    /// - Returns: UIImage of the palette card
    func generatePaletteCard(palette: Palette, size: CGSize = CGSize(width: 1080, height: 1920)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let cgContext = context.cgContext

            // Background gradient
            drawBackground(context: cgContext, size: size, colors: palette.sortedColors)

            // Draw source image if available
            if let thumbnail = palette.thumbnailImage {
                drawThumbnail(context: cgContext, image: thumbnail, size: size)
            }

            // Draw palette name
            drawPaletteName(context: cgContext, name: palette.name, size: size)

            // Draw color swatches
            drawColorSwatches(context: cgContext, colors: palette.sortedColors, size: size)

            // Draw color details
            drawColorDetails(context: cgContext, colors: palette.sortedColors, size: size)

            // Draw branding
            drawBranding(context: cgContext, size: size)
        }
    }

    // MARK: - Drawing Methods

    private func drawBackground(context: CGContext, size: CGSize, colors: [ColorItem]) {
        // Create subtle gradient background
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let gradientColors = colors.isEmpty ? [UIColor.systemBackground.cgColor, UIColor.systemGray6.cgColor] : colors.map { UIColor(red: $0.red, green: $0.green, blue: $0.blue, alpha: 0.1).cgColor }

        guard let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: gradientColors as CFArray,
            locations: nil
        ) else { return }

        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size.width, y: size.height),
            options: []
        )

        // Add white overlay for readability
        context.setFillColor(UIColor.white.withAlphaComponent(0.95).cgColor)
        context.fill(CGRect(origin: .zero, size: size))
    }

    private func drawThumbnail(context: CGContext, image: UIImage, size: CGSize) {
        let thumbnailHeight: CGFloat = size.height * 0.3
        let thumbnailWidth: CGFloat = size.width * 0.8
        let thumbnailX: CGFloat = (size.width - thumbnailWidth) / 2
        let thumbnailY: CGFloat = size.height * 0.1

        let thumbnailRect = CGRect(x: thumbnailX, y: thumbnailY, width: thumbnailWidth, height: thumbnailHeight)

        // Draw with rounded corners
        let path = UIBezierPath(roundedRect: thumbnailRect, cornerRadius: 20)
        context.addPath(path.cgPath)
        context.clip()

        image.draw(in: thumbnailRect)
        context.resetClip()

        // Draw shadow
        context.setShadow(offset: CGSize(width: 0, height: 4), blur: 20, color: UIColor.black.withAlphaComponent(0.1).cgColor)
    }

    private func drawPaletteName(context: CGContext, name: String, size: CGSize) {
        let nameY: CGFloat = size.height * 0.45

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 48, weight: .bold),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]

        let nameRect = CGRect(x: 60, y: nameY, width: size.width - 120, height: 60)
        name.draw(in: nameRect, withAttributes: attributes)
    }

    private func drawColorSwatches(context: CGContext, colors: [ColorItem], size: CGSize) {
        let swatchStartY: CGFloat = size.height * 0.55
        let swatchHeight: CGFloat = 120
        let spacing: CGFloat = 20
        let horizontalPadding: CGFloat = 60

        let totalWidth = size.width - (horizontalPadding * 2)
        let swatchWidth = (totalWidth - (spacing * CGFloat(colors.count - 1))) / CGFloat(colors.count)

        for (index, color) in colors.enumerated() {
            let x = horizontalPadding + (swatchWidth + spacing) * CGFloat(index)
            let rect = CGRect(x: x, y: swatchStartY, width: swatchWidth, height: swatchHeight)

            // Draw swatch with rounded corners
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 12)
            context.addPath(path.cgPath)

            context.setFillColor(red: color.red, green: color.green, blue: color.blue, alpha: 1.0)
            context.fillPath()

            // Draw subtle border
            context.setStrokeColor(UIColor.black.withAlphaComponent(0.1).cgColor)
            context.setLineWidth(2)
            context.addPath(path.cgPath)
            context.strokePath()
        }
    }

    private func drawColorDetails(context: CGContext, colors: [ColorItem], size: CGSize) {
        let detailsStartY: CGFloat = size.height * 0.75
        let spacing: CGFloat = 20
        let horizontalPadding: CGFloat = 60

        let totalWidth = size.width - (horizontalPadding * 2)
        let columnWidth = (totalWidth - (spacing * CGFloat(colors.count - 1))) / CGFloat(colors.count)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        for (index, color) in colors.enumerated() {
            let x = horizontalPadding + (columnWidth + spacing) * CGFloat(index)

            // HEX value
            let hexAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]

            let hexRect = CGRect(x: x, y: detailsStartY, width: columnWidth, height: 25)
            color.hexString.draw(in: hexRect, withAttributes: hexAttributes)

            // RGB value
            let rgbAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: paragraphStyle
            ]

            let rgbRect = CGRect(x: x, y: detailsStartY + 30, width: columnWidth, height: 18)
            color.rgbString.draw(in: rgbRect, withAttributes: rgbAttributes)
        }
    }

    private func drawBranding(context: CGContext, size: CGSize) {
        let brandingY: CGFloat = size.height - 100

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraphStyle
        ]

        let brandingRect = CGRect(x: 60, y: brandingY, width: size.width - 120, height: 30)
        "Created with PaletteSnap".draw(in: brandingRect, withAttributes: attributes)
    }

    // MARK: - Export Methods

    /// Save image to photo library
    func saveToPhotos(image: UIImage) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            continuation.resume()
        }
    }

    /// Get image data for sharing
    func getImageData(image: UIImage, format: ImageFormat = .png) -> Data? {
        switch format {
        case .png:
            return image.pngData()
        case .jpeg(let quality):
            return image.jpegData(compressionQuality: quality)
        }
    }
}

// MARK: - Supporting Types

enum ImageFormat {
    case png
    case jpeg(quality: CGFloat)
}
