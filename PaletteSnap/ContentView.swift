import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Palette.self, PaletteFolder.self])
}
