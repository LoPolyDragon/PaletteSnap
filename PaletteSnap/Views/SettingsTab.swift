import SwiftUI
import SwiftData

struct SettingsTab: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var palettes: [Palette]
    @Query private var folders: [PaletteFolder]

    @AppStorage("defaultColorCount") private var defaultColorCount = 6
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("autoSaveImages") private var autoSaveImages = true

    @State private var showDeleteAllAlert = false

    var body: some View {
        NavigationStack {
            List {
                extractionSettingsSection
                feedbackSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .alert("Delete All Data", isPresented: $showDeleteAllAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will delete all palettes and folders. This action cannot be undone.")
            }
        }
    }

    private var extractionSettingsSection: some View {
        Section {
            Stepper("Colors to Extract: \(defaultColorCount)", value: $defaultColorCount, in: 3...10)

            Toggle("Auto-save Images", isOn: $autoSaveImages)
        } header: {
            Text("Extraction")
        } footer: {
            Text("Number of colors to extract from each photo. More colors provide more variety but may take longer.")
        }
    }

    private var feedbackSection: some View {
        Section {
            Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
        } header: {
            Text("Feedback")
        } footer: {
            Text("Provide tactile feedback for interactions throughout the app.")
        }
    }

    private var dataSection: some View {
        Section {
            HStack {
                Text("Saved Palettes")
                Spacer()
                Text("\(palettes.count)")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Folders")
                Spacer()
                Text("\(folders.count)")
                    .foregroundStyle(.secondary)
            }

            Button(role: .destructive) {
                showDeleteAllAlert = true
            } label: {
                Label("Delete All Data", systemImage: "trash")
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Data")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            Link(destination: URL(string: "https://github.com")!) {
                HStack {
                    Text("GitHub Repository")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Link(destination: URL(string: "https://github.com")!) {
                HStack {
                    Text("Report an Issue")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("About")
        } footer: {
            VStack(alignment: .leading, spacing: 8) {
                Text("PaletteSnap")
                    .font(.headline)

                Text("Extract beautiful color palettes from photos. Created for designers, artists, and color enthusiasts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("© 2024 PaletteSnap. All rights reserved.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
    }

    private func deleteAllData() {
        do {
            try modelContext.delete(model: Palette.self)
            try modelContext.delete(model: PaletteFolder.self)
            try modelContext.save()
            HapticFeedbackService.shared.success()
        } catch {
            print("Error deleting data: \(error)")
            HapticFeedbackService.shared.error()
        }
    }
}

#Preview {
    SettingsTab()
        .modelContainer(for: [Palette.self, PaletteFolder.self])
}
