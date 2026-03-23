import SwiftUI

struct ColorDetailView: View {
    let colorItem: ColorItem
    @State private var showingCopiedConfirmation = false
    @State private var copiedValue: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Color swatch
            RoundedRectangle(cornerRadius: 12)
                .fill(colorItem.color)
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: colorItem.color.opacity(0.3), radius: 8, x: 0, y: 4)

            // Color values
            VStack(spacing: 8) {
                // HEX value
                colorValueButton(
                    title: "HEX",
                    value: colorItem.hexString,
                    icon: "number"
                )

                Divider()

                // RGB value
                colorValueButton(
                    title: "RGB",
                    value: colorItem.rgbString,
                    icon: "square.grid.3x3"
                )

                Divider()

                // HSL value
                colorValueButton(
                    title: "HSL",
                    value: colorItem.hslString,
                    icon: "paintbrush"
                )
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
            )
        }
        .overlay(alignment: .top) {
            if showingCopiedConfirmation {
                copiedConfirmationView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func colorValueButton(title: String, value: String, icon: String) -> some View {
        Button {
            copyToClipboard(value)
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(value)
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }

                Spacer()

                Image(systemName: "doc.on.doc")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var copiedConfirmationView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.white)

                Text("Copied \(copiedValue)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.green)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 8)
    }

    private func copyToClipboard(_ value: String) {
        UIPasteboard.general.string = value
        HapticFeedbackService.shared.success()

        copiedValue = value

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showingCopiedConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingCopiedConfirmation = false
            }
        }
    }
}

#Preview {
    ColorDetailView(
        colorItem: ColorItem(red: 0.3, green: 0.6, blue: 0.9)
    )
    .padding()
    .frame(width: 200)
}
