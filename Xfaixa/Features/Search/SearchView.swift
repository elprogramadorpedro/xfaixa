import SwiftUI

/// Search tab: looks up songs in the iTunes catalog as the user types.
struct SearchView: View {

    // MARK: - Properties

    @State private var viewModel: SearchViewModel
    @Environment(FavoritesStore.self) private var favoritesStore
    @Environment(PlayerService.self) private var player

    private let connectivity: any ConnectivityMonitoring

    private static let chipTints: [Color] = [.tropicalOrange, .pineappleYellow, .leafGreen]

    // MARK: - Init

    init(searchService: any MusicSearchService, connectivity: any ConnectivityMonitoring) {
        self.connectivity = connectivity
        _viewModel = State(initialValue: SearchViewModel(searchService: searchService, connectivity: connectivity))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background { TropicalBackground() }
                .navigationTitle("Buscar")
                .animation(.smooth, value: viewModel.state)
        }
        .searchable(text: $viewModel.query, prompt: "Artistas, músicas ou álbuns")
        .task(id: viewModel.query) {
            await viewModel.search()
        }
        .task(id: connectivity.isConnected) {
            await viewModel.connectivityChanged(isConnected: connectivity.isConnected)
        }
    }

    // MARK: - States

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            suggestions
        case .loading:
            songList(Song.previews, isPlaceholder: true)
        case .loaded(let songs):
            songList(songs, isPlaceholder: false)
        case .empty:
            EmptyStateView(
                "Nada encontrado",
                systemImage: "magnifyingglass",
                message: "Não encontramos músicas para “\(viewModel.query)”. Tente outro termo."
            )
        case .failed(let error):
            EmptyStateView(
                "Não foi possível buscar",
                systemImage: error == .offline ? "wifi.slash" : "exclamationmark.triangle.fill",
                message: "\(error.message)",
                actionTitle: "Tentar novamente"
            ) {
                Task { await viewModel.retry() }
            }
        }
    }

    private var suggestions: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("O que vamos ouvir hoje?")
                        .font(Typography.title)
                        .foregroundStyle(Color.textPrimary)
                    Text("Comece por uma sugestão ou busque pelo seu artista favorito.")
                        .font(Typography.callout)
                        .foregroundStyle(Color.textSecondary)
                }

                // One container lets neighbouring chips blend into a single glass layer.
                GlassEffectContainer(spacing: Spacing.xs) {
                    FlowLayout(spacing: Spacing.xs) {
                        ForEach(Array(viewModel.suggestions.enumerated()), id: \.element) { index, suggestion in
                            ChipButton(
                                title: suggestion,
                                systemImage: "music.note",
                                tint: Self.chipTints[index % Self.chipTints.count].opacity(0.2)
                            ) {
                                viewModel.selectSuggestion(suggestion)
                            }
                        }
                    }
                }
            }
            .padding(Spacing.lg)
        }
        .transition(.opacity)
    }

    private func songList(_ songs: [Song], isPlaceholder: Bool) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.sm) {
                Group {
                    if isPlaceholder {
                        Text("Buscando…")
                    } else {
                        Text("^[\(songs.count) música](inflect: true)")
                    }
                }
                .font(Typography.caption)
                .foregroundStyle(Color.textSecondary)
                .padding(.horizontal, Spacing.xs)

                ForEach(songs) { song in
                    SongRow(
                        title: song.title,
                        artist: song.artist,
                        artworkURL: isPlaceholder ? nil : song.artworkURL,
                        isFavorite: !isPlaceholder && favoritesStore.isFavorite(song),
                        isPlaying: !isPlaceholder && player.isPlaying(song),
                        onToggleFavorite: { favoritesStore.toggle(song) },
                        onTogglePlay: { player.toggle(song) }
                    )
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
        .redacted(reason: isPlaceholder ? .placeholder : [])
        .allowsHitTesting(!isPlaceholder)
        .transition(.opacity)
    }
}

#Preview("Results") {
    SearchView(searchService: PreviewMusicSearchService(), connectivity: StaticConnectivityMonitor())
        .environment(FavoritesStore.preview())
        .environment(PlayerService())
}

#Preview("Offline") {
    SearchView(searchService: PreviewMusicSearchService(), connectivity: StaticConnectivityMonitor(isConnected: false))
        .environment(FavoritesStore.preview(seeded: false))
        .environment(PlayerService())
}
