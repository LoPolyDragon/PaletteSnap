import SwiftUI
import PhotosUI
import SwiftData

struct ExtractTab: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var extractedColors: [ColorItem] = []
    @State private var isExtracting = false
    @State private var showSaveSheet = false
    @State private var showColorPicker = false
    @State private var selectedColorIndex: Int?
    @State private var showHarmonySheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 24) {
                        if let image = selectedImage {
                            imagePreviewSection(image: image)
                            extractedColorsSection
                            colorHarmonySection
                        } else {
                            emptyStateSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Extract Colors")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedImage != nil {
                        Menu {
                            Button {
                                showSaveSheet = true
                            } label: {
                                Label("Save Palette", systemImage: "square.and.arrow.down")
                            }
                            .disabled(extractedColors.isEmpty)

                            Button(role: .destructive) {
                                clearSelection()
                            } label: {
                                Label("Clear", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSaveSheet) {
                SavePaletteSheet(
                    colors: extractedColors,
                    imageData: selectedImage?.jpegData(compressionQuality: 0.8)
                )
            }
            .sheet(isPresented: $showColorPicker) {
                if let index = selectedColorIndex, extractedColors.indices.contains(index) {
                    ColorPickerSheet(colorItem: $extractedColors[index])
                }
            }
            .sheet(isPresented: $showHarmonySheet) {
                ColorHarmonySheet(colors: extractedColors)
            }
        }
    }

    // MARK: - View Components

    private var backgroundGradient: some View {
        LinearGradient(
            colors: extractedColors.isEmpty
                ? [Color(.systemBackground), Color(.systemGray6)]
                : extractedColors.map { $0.color.opacity(0.1) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.8), value: extractedColors.count)
    }

    private var emptyStateSection: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)

                Text("Extract Colors from Photos")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Select a photo to extract its dominant colors and create beautiful palettes")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 16) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        await loadPhoto(from: newValue)
                    }
                }

                CameraButton(selectedImage: $selectedImage)
                    .onChange(of: selectedImage) { _, _ in
                        Task {
                            await extractColors()
                        }
                    }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    private func imagePreviewSection(image: UIImage) -> some View {
        VStack(spacing: 16) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("Change Photo", systemImage: "photo")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    await loadPhoto(from: newValue)
                }
            }
        }
    }

    @ViewBuilder
    private var extractedColorsSection: some View {
        if !extractedColors.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Extracted Colors")
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Text("\(extractedColors.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Array(extractedColors.enumerated()), id: \.offset) { index, color in
                        ColorDetailView(colorItem: color)
                            .onLongPressGesture {
                                HapticFeedbackService.shared.mediumImpact()
                                selectedColorIndex = index
                                showColorPicker = true
                            }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        } else if isExtracting {
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)

                Text("Extracting colors...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
            .background(Color(.systemBackground))
            .cornerRadius(20)
        }
    }

    @ViewBuilder
    private var colorHarmonySection: some View {
        if !extractedColors.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Color Harmony")
                    .font(.title3)
                    .fontWeight(.bold)

                Button {
                    showHarmonySheet = true
                } label: {
                    HStack {
                        Image(systemName: "paintpalette")
                        Text("Explore Color Harmonies")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundStyle(Color.accentColor)
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }

    // MARK: - Actions

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                await extractColors()
            }
        } catch {
            print("Error loading photo: \(error)")
        }
    }

    private func extractColors() async {
        guard let image = selectedImage else { return }

        isExtracting = true

        do {
            let colors = try await ColorExtractionService.shared.extractColors(from: image, colorCount: 6)
            await MainActor.run {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    extractedColors = colors
                }
                isExtracting = false
                HapticFeedbackService.shared.success()
            }
        } catch {
            await MainActor.run {
                isExtracting = false
                HapticFeedbackService.shared.error()
            }
            print("Error extracting colors: \(error)")
        }
    }

    private func clearSelection() {
        withAnimation {
            selectedImage = nil
            extractedColors = []
            selectedPhoto = nil
        }
        HapticFeedbackService.shared.lightImpact()
    }
}

// MARK: - Camera Button

struct CameraButton: View {
    @Binding var selectedImage: UIImage?
    @State private var showCamera = false

    var body: some View {
        Button {
            showCamera = true
        } label: {
            Label("Take Photo", systemImage: "camera")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundStyle(.primary)
                .cornerRadius(12)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(selectedImage: $selectedImage)
        }
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ExtractTab()
        .modelContainer(for: [Palette.self, PaletteFolder.self])
}
