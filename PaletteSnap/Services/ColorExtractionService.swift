import UIKit
import Accelerate
import CoreImage

/// Service for extracting dominant colors from images using k-means clustering
final class ColorExtractionService {
    static let shared = ColorExtractionService()

    private init() {}

    /// Extract dominant colors from an image
    /// - Parameters:
    ///   - image: The source image
    ///   - colorCount: Number of colors to extract (5-8 recommended)
    /// - Returns: Array of extracted ColorItem objects
    func extractColors(from image: UIImage, colorCount: Int = 6) async throws -> [ColorItem] {
        // Downsample image for performance
        guard let downsampledImage = downsample(image: image, to: CGSize(width: 200, height: 200)) else {
            throw ColorExtractionError.invalidImage
        }

        // Extract pixel data
        guard let pixelData = extractPixelData(from: downsampledImage) else {
            throw ColorExtractionError.pixelExtractionFailed
        }

        // Perform k-means clustering
        let clusters = performKMeans(pixelData: pixelData, k: colorCount, maxIterations: 20)

        // Sort clusters by size (most prominent colors first)
        let sortedClusters = clusters.sorted { $0.pointCount > $1.pointCount }

        // Convert to ColorItem objects
        return sortedClusters.enumerated().map { index, cluster in
            ColorItem(
                red: Double(cluster.centroid.r),
                green: Double(cluster.centroid.g),
                blue: Double(cluster.centroid.b),
                position: index
            )
        }
    }

    // MARK: - Private Methods

    /// Downsample image to improve performance
    private func downsample(image: UIImage, to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// Extract RGB pixel data from image
    private func extractPixelData(from image: UIImage) -> [RGBPixel]? {
        guard let cgImage = image.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Convert to RGB pixels, sampling every few pixels for performance
        var pixels: [RGBPixel] = []
        let stride = 2 // Sample every 2nd pixel

        for y in stride(from: 0, to: height, by: stride) {
            for x in stride(from: 0, to: width, by: stride) {
                let offset = (y * width + x) * bytesPerPixel
                let r = Float(pixelData[offset]) / 255.0
                let g = Float(pixelData[offset + 1]) / 255.0
                let b = Float(pixelData[offset + 2]) / 255.0
                let a = Float(pixelData[offset + 3]) / 255.0

                // Skip transparent pixels
                if a > 0.5 {
                    pixels.append(RGBPixel(r: r, g: g, b: b))
                }
            }
        }

        return pixels
    }

    /// Perform k-means clustering on pixel data
    private func performKMeans(pixelData: [RGBPixel], k: Int, maxIterations: Int) -> [Cluster] {
        guard !pixelData.isEmpty, k > 0 else { return [] }

        // Initialize centroids randomly from existing pixels
        var centroids = (0..<k).map { _ in
            pixelData.randomElement() ?? RGBPixel(r: 0.5, g: 0.5, b: 0.5)
        }

        var clusters: [Cluster] = []

        for _ in 0..<maxIterations {
            // Assign pixels to nearest centroid
            var assignments = [Int: [RGBPixel]]()
            for i in 0..<k {
                assignments[i] = []
            }

            for pixel in pixelData {
                let nearestCentroidIndex = findNearestCentroid(pixel: pixel, centroids: centroids)
                assignments[nearestCentroidIndex]?.append(pixel)
            }

            // Update centroids
            var newCentroids: [RGBPixel] = []
            clusters = []

            for i in 0..<k {
                guard let pixels = assignments[i], !pixels.isEmpty else {
                    // Keep old centroid if no pixels assigned
                    newCentroids.append(centroids[i])
                    clusters.append(Cluster(centroid: centroids[i], pointCount: 0))
                    continue
                }

                let newCentroid = calculateMean(pixels: pixels)
                newCentroids.append(newCentroid)
                clusters.append(Cluster(centroid: newCentroid, pointCount: pixels.count))
            }

            // Check for convergence
            let converged = zip(centroids, newCentroids).allSatisfy { old, new in
                distance(old, new) < 0.01
            }

            centroids = newCentroids

            if converged {
                break
            }
        }

        return clusters
    }

    /// Find the nearest centroid for a pixel
    private func findNearestCentroid(pixel: RGBPixel, centroids: [RGBPixel]) -> Int {
        var minDistance = Float.greatestFiniteMagnitude
        var nearestIndex = 0

        for (index, centroid) in centroids.enumerated() {
            let dist = distance(pixel, centroid)
            if dist < minDistance {
                minDistance = dist
                nearestIndex = index
            }
        }

        return nearestIndex
    }

    /// Calculate Euclidean distance between two pixels
    private func distance(_ p1: RGBPixel, _ p2: RGBPixel) -> Float {
        let dr = p1.r - p2.r
        let dg = p1.g - p2.g
        let db = p1.b - p2.b
        return sqrt(dr * dr + dg * dg + db * db)
    }

    /// Calculate mean color of pixels
    private func calculateMean(pixels: [RGBPixel]) -> RGBPixel {
        let count = Float(pixels.count)
        let sumR = pixels.reduce(0) { $0 + $1.r }
        let sumG = pixels.reduce(0) { $0 + $1.g }
        let sumB = pixels.reduce(0) { $0 + $1.b }

        return RGBPixel(
            r: sumR / count,
            g: sumG / count,
            b: sumB / count
        )
    }
}

// MARK: - Supporting Types

struct RGBPixel {
    let r: Float
    let g: Float
    let b: Float
}

struct Cluster {
    let centroid: RGBPixel
    let pointCount: Int
}

enum ColorExtractionError: LocalizedError {
    case invalidImage
    case pixelExtractionFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The provided image is invalid or cannot be processed."
        case .pixelExtractionFailed:
            return "Failed to extract pixel data from the image."
        }
    }
}
