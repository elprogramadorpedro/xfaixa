import SwiftUI

/// Favorites tab: songs the user saved, available offline.
struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            EmptyStateView(
                "Nenhum favorito ainda",
                message: "Toque no coração de uma música para guardá-la aqui."
            ) {
                PineappleView(size: 88)
            }
            .frame(maxHeight: .infinity)
            .background { TropicalBackground() }
            .navigationTitle("Favoritos")
        }
    }
}

#Preview {
    FavoritesView()
}
