import SwiftUI

struct ColorHarmonySheet: View {
    @Environment(\.dismiss) private var dismiss
    let colors: [ColorItem]

    @State private var selectedColorIndex: Int = 0
    @State private var selectedHarmonyType: HarmonyType = .complementary

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Base color selection
                    baseColorSection

                    // Harmony type selection
                    harmonyTypeSection

                    // Generated harmonies
                    harmoniesSection
                }
                .padding()
            }
            .navigationTitle("Color Harmony")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var baseColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Base Color")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(color.color)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            selectedColorIndex == index ? Color.primary : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: color.color.opacity(0.3), radius: 8, x: 0, y: 4)

                            Text(color.hexString)
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .onTapGesture {
                            selectedColorIndex = index
                            HapticFeedbackService.shared.selectionChanged()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private var harmonyTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Harmony Type")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(HarmonyType.allCases) { type in
                    harmonyTypeButton(type)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private func harmonyTypeButton(_ type: HarmonyType) -> some View {
        Button {
            selectedHarmonyType = type
            HapticFeedbackService.shared.selectionChanged()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: type.iconName)
                    .font(.title2)

                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                selectedHarmonyType == type
                    ? Color.accentColor.opacity(0.2)
                    : Color(.systemGray6)
            )
            .foregroundStyle(
                selectedHarmonyType == type
                    ? Color.accentColor
                    : Color.primary
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var harmoniesSection: some View {
        if colors.indices.contains(selectedColorIndex) {
            let baseColor = colors[selectedColorIndex]
            let harmonyColors = generateHarmonyColors(for: baseColor)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(selectedHarmonyType.rawValue)
                        .font(.headline)

                    Spacer()

                    Text("\(harmonyColors.count) colors")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(selectedHarmonyType.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Array(harmonyColors.enumerated()), id: \.offset) { _, color in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(color.color)
                                .frame(height: 100)
                                .shadow(color: color.color.opacity(0.3), radius: 8, x: 0, y: 4)

                            VStack(spacing: 4) {
                                Text(color.hexString)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .fontDesign(.monospaced)

                                Button {
                                    UIPasteboard.general.string = color.hexString
                                    HapticFeedbackService.shared.success()
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }

    private func generateHarmonyColors(for color: ColorItem) -> [ColorItem] {
        let service = ColorHarmonyService.shared

        switch selectedHarmonyType {
        case .complementary:
            return [service.complementary(for: color)]
        case .analogous:
            return service.analogous(for: color)
        case .triadic:
            return service.triadic(for: color)
        case .splitComplementary:
            return service.splitComplementary(for: color)
        case .tetradic:
            return service.tetradic(for: color)
        case .monochromatic:
            return service.monochromatic(for: color, count: 6)
        case .shades:
            return service.shades(for: color, count: 6)
        case .tints:
            return service.tints(for: color, count: 6)
        }
    }
}

#Preview {
    ColorHarmonySheet(colors: [
        ColorItem(red: 0.3, green: 0.6, blue: 0.9),
        ColorItem(red: 0.9, green: 0.3, blue: 0.6),
        ColorItem(red: 0.6, green: 0.9, blue: 0.3)
    ])
}
