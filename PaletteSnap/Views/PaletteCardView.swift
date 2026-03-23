import SwiftUI

struct PaletteCardView: View {
    let palette: Palette

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail or gradient
            if let imageData = palette.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
            } else {
                palette.gradient
                    .frame(height: 120)
            }

            // Color swatches
            HStack(spacing: 0) {
                ForEach(palette.sortedColors.prefix(5), id: \.hexString) { color in
                    Rectangle()
                        .fill(color.color)
                        .frame(height: 40)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(palette.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                HStack {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.caption2)

                    Text("\(palette.colors.count) colors")
                        .font(.caption)

                    Spacer()

                    if let folder = palette.folder {
                        Circle()
                            .fill(folder.color)
                            .frame(width: 8, height: 8)
                    }
                }
                .foregroundStyle(.secondary)
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    PaletteCardView(
        palette: Palette(
            name: "Summer Sunset",
            colors: [
                ColorItem(red: 0.9, green: 0.5, blue: 0.2),
                ColorItem(red: 0.8, green: 0.3, blue: 0.4),
                ColorItem(red: 0.6, green: 0.2, blue: 0.8)
            ]
        )
    )
    .frame(width: 180)
    .padding()
}
