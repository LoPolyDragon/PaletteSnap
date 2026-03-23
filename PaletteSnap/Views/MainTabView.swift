import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ExtractTab()
                .tabItem {
                    Label("Extract", systemImage: "photo.badge.plus")
                }
                .tag(0)

            PalettesTab()
                .tabItem {
                    Label("Palettes", systemImage: "square.stack.3d.up")
                }
                .tag(1)

            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .onChange(of: selectedTab) { _, _ in
            HapticFeedbackService.shared.selectionChanged()
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Palette.self, PaletteFolder.self])
}
