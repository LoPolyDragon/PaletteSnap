import SwiftUI
import SwiftData

struct PalettesTab: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Palette.createdAt, order: .reverse) private var palettes: [Palette]
    @Query(sort: \PaletteFolder.name) private var folders: [PaletteFolder]

    @State private var selectedPalette: Palette?
    @State private var showingDeleteAlert = false
    @State private var paletteToDelete: Palette?
    @State private var selectedFolder: PaletteFolder?
    @State private var searchText = ""

    var filteredPalettes: [Palette] {
        var result = palettes

        // Filter by folder
        if let folder = selectedFolder {
            result = result.filter { $0.folder?.id == folder.id }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { palette in
                palette.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if palettes.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            if !folders.isEmpty {
                                folderFilterSection
                            }

                            palettesGridSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Palettes")
            .searchable(text: $searchText, prompt: "Search palettes")
            .sheet(item: $selectedPalette) { palette in
                PaletteDetailView(palette: palette)
            }
            .alert("Delete Palette", isPresented: $showingDeleteAlert, presenting: paletteToDelete) { palette in
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deletePalette(palette)
                }
            } message: { palette in
                Text("Are you sure you want to delete \"\(palette.name)\"?")
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("No Saved Palettes")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Extract colors from photos to create and save palettes")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    private var folderFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    count: palettes.count,
                    isSelected: selectedFolder == nil
                ) {
                    selectedFolder = nil
                    HapticFeedbackService.shared.selectionChanged()
                }

                ForEach(folders) { folder in
                    FilterChip(
                        title: folder.name,
                        count: folder.paletteCount,
                        color: folder.color,
                        isSelected: selectedFolder?.id == folder.id
                    ) {
                        selectedFolder = folder
                        HapticFeedbackService.shared.selectionChanged()
                    }
                }
            }
        }
    }

    private var palettesGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(filteredPalettes) { palette in
                PaletteCardView(palette: palette)
                    .onTapGesture {
                        selectedPalette = palette
                        HapticFeedbackService.shared.lightImpact()
                    }
                    .contextMenu {
                        Button {
                            selectedPalette = palette
                        } label: {
                            Label("View Details", systemImage: "info.circle")
                        }

                        Button(role: .destructive) {
                            paletteToDelete = palette
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }

    private func deletePalette(_ palette: Palette) {
        modelContext.delete(palette)
        HapticFeedbackService.shared.heavyImpact()
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let count: Int
    var color: Color = .accentColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if !isSelected && title != "All" {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)

                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.white.opacity(0.3) : Color(.systemGray5))
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color(.systemGray6))
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Palette Detail View

struct PaletteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let palette: Palette

    @State private var showShareSheet = false
    @State private var exportedImage: UIImage?
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let imageData = palette.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                    }

                    VStack(spacing: 16) {
                        HStack {
                            Text("Colors")
                                .font(.title3)
                                .fontWeight(.bold)

                            Spacer()

                            Text("\(palette.colors.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(palette.sortedColors, id: \.hexString) { color in
                                ColorDetailView(colorItem: color)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)

                    if let folder = palette.folder {
                        HStack {
                            Circle()
                                .fill(folder.color)
                                .frame(width: 12, height: 12)

                            Text("Folder: \(folder.name)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Spacer()
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle(palette.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        exportPalette()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .loadingOverlay(isExporting)
            .sheet(isPresented: $showShareSheet) {
                if let image = exportedImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }

    private func exportPalette() {
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            let image = ImageExportService.shared.generatePaletteCard(palette: palette)

            DispatchQueue.main.async {
                exportedImage = image
                isExporting = false

                if image != nil {
                    showShareSheet = true
                    HapticFeedbackService.shared.success()
                } else {
                    HapticFeedbackService.shared.error()
                }
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    PalettesTab()
        .modelContainer(for: [Palette.self, PaletteFolder.self])
}
