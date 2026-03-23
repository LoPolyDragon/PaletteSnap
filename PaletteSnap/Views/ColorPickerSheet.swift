import SwiftUI

struct ColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var colorItem: ColorItem

    @State private var selectedColor: Color

    init(colorItem: Binding<ColorItem>) {
        self._colorItem = colorItem
        self._selectedColor = State(initialValue: colorItem.wrappedValue.color)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Preview
                VStack(spacing: 16) {
                    Text("Adjust Color")
                        .font(.headline)

                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedColor)
                        .frame(height: 200)
                        .shadow(color: selectedColor.opacity(0.4), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                        )
                }
                .padding()

                // Color Picker
                ColorPicker("Select Color", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .padding()

                // Color Values
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color Values")
                        .font(.headline)

                    colorValueRow(title: "HEX", value: selectedColor.hexString ?? "#000000")
                    colorValueRow(title: "RGB", value: rgbString)
                    colorValueRow(title: "HSL", value: hslString)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding()

                Spacer()
            }
            .navigationTitle("Color Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveColor()
                    }
                }
            }
        }
    }

    private func colorValueRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)

            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.medium)

            Spacer()
        }
    }

    private var rgbString: String {
        guard let components = UIColor(selectedColor).cgColor.components,
              components.count >= 3 else {
            return "RGB(0, 0, 0)"
        }

        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)

        return "RGB(\(r), \(g), \(b))"
    }

    private var hslString: String {
        guard let components = UIColor(selectedColor).cgColor.components,
              components.count >= 3 else {
            return "HSL(0°, 0%, 0%)"
        }

        let hsl = ColorItem.rgbToHSL(r: Double(components[0]), g: Double(components[1]), b: Double(components[2]))

        return "HSL(\(Int(hsl.h))°, \(Int(hsl.s * 100))%, \(Int(hsl.l * 100))%)"
    }

    private func saveColor() {
        guard let components = UIColor(selectedColor).cgColor.components,
              components.count >= 3 else {
            dismiss()
            return
        }

        let newColorItem = ColorItem(
            red: Double(components[0]),
            green: Double(components[1]),
            blue: Double(components[2]),
            position: colorItem.position
        )

        colorItem = newColorItem
        HapticFeedbackService.shared.success()
        dismiss()
    }
}

#Preview {
    ColorPickerSheet(
        colorItem: .constant(ColorItem(red: 0.3, green: 0.6, blue: 0.9))
    )
}
