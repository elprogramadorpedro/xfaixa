import SwiftUI

/// Favorites tab: songs the user saved, read from local storage so it works offline.
struct FavoritesView: View {

    // MARK: - Properties

    let onBrowse: () -> Void

    @Environment(FavoritesStore.self) private var favoritesStore

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if favoritesStore.favorites.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { TropicalBackground() }
            .navigationTitle("Favoritos")
            .animation(.smooth, value: favoritesStore.favoriteIDs)
            .sensoryFeedback(.impact(weight: .light), trigger: favoritesStore.count)
        }
    }

    // MARK: - Private Helpers

    private var list: some View {
        List {
            Section {
                ForEach(favoritesStore.favorites) { favorite in
                    SongRow(
                        title: favorite.title,
                        artist: favorite.artist,
                        artworkURL: favorite.artworkURL,
                        artworkData: favorite.artworkData,
                        isFavorite: true,
                        onToggleFavorite: { favoritesStore.remove(songId: favorite.songId) },
                        onTogglePlay: {}
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: Spacing.xxs, leading: Spacing.md, bottom: Spacing.xxs, trailing: Spacing.md))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            favoritesStore.remove(songId: favorite.songId)
                        } label: {
                            Label("Remover", systemImage: "heart.slash.fill")
                        }
                    }
                }
            } header: {
                Text("^[\(favoritesStore.count) música](inflect: true)")
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        EmptyStateView(
            "Nenhum favorito ainda",
            message: "Toque no coração de uma música para guardá-la aqui. Ela fica disponível mesmo sem internet.",
            actionTitle: "Buscar músicas",
            action: onBrowse
        ) {
            PineappleView(size: 96, isSwaying: true)
        }
    }
}

#Preview("With favorites") {
    FavoritesView {}
        .environment(FavoritesStore.preview())
}

#Preview("Empty") {
    FavoritesView {}
        .environment(FavoritesStore.preview(seeded: false))
}
