import SwiftUI
import UIKit

extension UIImage {
    /// Resize image while maintaining aspect ratio
    func resized(to targetSize: CGSize) -> UIImage? {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        let scaledSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }

    /// Generate a thumbnail of the image
    func thumbnail(maxSize: CGFloat = 200) -> UIImage? {
        let targetSize = CGSize(width: maxSize, height: maxSize)
        return resized(to: targetSize)
    }

    /// Compress image to target file size (in bytes)
    func compressed(toMaxBytes maxBytes: Int) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = self.jpegData(compressionQuality: compression)

        while let data = imageData, data.count > maxBytes, compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }

        return imageData
    }

    /// Create a blurred version of the image
    func blurred(radius: CGFloat = 10) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }

        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey)

        guard let outputImage = filter?.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    /// Calculate average color of the image
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: inputImage,
            kCIInputExtentKey: extentVector
        ]) else { return nil }

        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])

        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: CGFloat(bitmap[3]) / 255
        )
    }
}

extension Image {
    /// Initialize Image from Data
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        self.init(uiImage: uiImage)
    }
}
