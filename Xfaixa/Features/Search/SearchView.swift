import SwiftUI

/// Search tab: looks up songs in the iTunes catalog.
struct SearchView: View {
    var body: some View {
        NavigationStack {
            EmptyStateView(
                "Busque sua música",
                systemImage: "music.note",
                message: "Encontre artistas, álbuns e canções."
            )
            .frame(maxHeight: .infinity)
            .background { TropicalBackground() }
            .navigationTitle("Buscar")
        }
    }
}

#Preview {
    SearchView()
}
