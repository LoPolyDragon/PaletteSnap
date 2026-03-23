import SwiftUI
import SwiftData

struct SavePaletteSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var folders: [PaletteFolder]

    let colors: [ColorItem]
    let imageData: Data?

    @State private var paletteName: String = ""
    @State private var selectedFolder: PaletteFolder?
    @State private var showCreateFolder = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Palette Name") {
                    TextField("Enter name", text: $paletteName)
                        .textFieldStyle(.plain)
                }

                Section("Folder") {
                    Picker("Select Folder", selection: $selectedFolder) {
                        Text("None")
                            .tag(nil as PaletteFolder?)

                        ForEach(folders) { folder in
                            HStack {
                                Circle()
                                    .fill(folder.color)
                                    .frame(width: 12, height: 12)
                                Text(folder.name)
                            }
                            .tag(folder as PaletteFolder?)
                        }
                    }

                    Button {
                        showCreateFolder = true
                    } label: {
                        Label("Create New Folder", systemImage: "folder.badge.plus")
                    }
                }

                Section("Preview") {
                    palettePreview
                }
            }
            .navigationTitle("Save Palette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePalette()
                    }
                    .disabled(paletteName.isEmpty)
                }
            }
            .sheet(isPresented: $showCreateFolder) {
                CreateFolderSheet(selectedFolder: $selectedFolder)
            }
            .onAppear {
                generateDefaultName()
            }
        }
    }

    private var palettePreview: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(colors, id: \.hexString) { color in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.color)
                        .frame(height: 60)
                }
            }

            Text("\(colors.count) colors")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func generateDefaultName() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        paletteName = "Palette - \(formatter.string(from: Date()))"
    }

    private func savePalette() {
        let palette = Palette(
            name: paletteName,
            colors: colors,
            imageData: imageData,
            folder: selectedFolder
        )

        modelContext.insert(palette)

        do {
            try modelContext.save()
            HapticFeedbackService.shared.success()
            dismiss()
        } catch {
            print("Error saving palette: \(error)")
            HapticFeedbackService.shared.error()
        }
    }
}

// MARK: - Create Folder Sheet

struct CreateFolderSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFolder: PaletteFolder?

    @State private var folderName: String = ""
    @State private var selectedColor: Color = .blue

    private let availableColors: [Color] = [
        .blue, .purple, .pink, .red, .orange, .yellow, .green, .teal, .indigo, .brown
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Folder Name") {
                    TextField("Enter name", text: $folderName)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(availableColors, id: \.description) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                    HapticFeedbackService.shared.selectionChanged()
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createFolder()
                    }
                    .disabled(folderName.isEmpty)
                }
            }
        }
    }

    private func createFolder() {
        let folder = PaletteFolder(
            name: folderName,
            colorHex: selectedColor.hexString ?? "#007AFF"
        )

        modelContext.insert(folder)

        do {
            try modelContext.save()
            selectedFolder = folder
            HapticFeedbackService.shared.success()
            dismiss()
        } catch {
            print("Error creating folder: \(error)")
            HapticFeedbackService.shared.error()
        }
    }
}

#Preview {
    SavePaletteSheet(
        colors: [
            ColorItem(red: 0.3, green: 0.6, blue: 0.9),
            ColorItem(red: 0.9, green: 0.3, blue: 0.6)
        ],
        imageData: nil
    )
    .modelContainer(for: [Palette.self, PaletteFolder.self])
}
