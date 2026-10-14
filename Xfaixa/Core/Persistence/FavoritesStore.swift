import Foundation
import OSLog
import SwiftData

/// Source of truth for the signed-in user's favorites. Persists to SwiftData and keeps an observable
/// snapshot, so a heart toggled in Search shows up in Favorites and Profile without refetching.
@MainActor
@Observable
final class FavoritesStore {
    typealias ArtworkLoader = @Sendable (URL) async throws -> Data

    // MARK: - Properties

    let userId: String

    private(set) var favorites: [FavoriteSong] = []
    private(set) var favoriteIDs: Set<Int> = []

    private let context: ModelContext
    private let loadArtwork: ArtworkLoader
    private let logger = Logger(subsystem: "devpedrovillalba.Xfaixa", category: "Favorites")

    // MARK: - Init

    init(
        userId: String,
        modelContainer: ModelContainer,
        loadArtwork: @escaping ArtworkLoader = { try await URLSession.shared.data(from: $0).0 }
    ) {
        self.userId = userId
        self.loadArtwork = loadArtwork
        context = modelContainer.mainContext
        reload()
    }

    // MARK: - Public API

    var count: Int { favorites.count }

    func isFavorite(_ song: Song) -> Bool {
        favoriteIDs.contains(song.id)
    }

    func toggle(_ song: Song) {
        if isFavorite(song) {
            remove(songId: song.id)
        } else {
            add(song)
        }
    }

    func add(_ song: Song) {
        guard !isFavorite(song) else { return }

        let favorite = FavoriteSong(song: song, userId: userId)
        context.insert(favorite)
        guard save() else { return }

        favorites.insert(favorite, at: 0)
        favoriteIDs.insert(song.id)

        if let artworkURL = song.artworkURL {
            Task { await cacheArtwork(for: favorite, from: artworkURL) }
        }
    }

    func remove(songId: Int) {
        guard let favorite = favorites.first(where: { $0.songId == songId }) else { return }

        context.delete(favorite)
        guard save() else { return }

        favorites.removeAll { $0.songId == songId }
        favoriteIDs.remove(songId)
    }

    // MARK: - Private Helpers

    private func reload() {
        let userId = userId
        let descriptor = FetchDescriptor<FavoriteSong>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        do {
            favorites = try context.fetch(descriptor)
        } catch {
            logger.error("Failed to load favorites: \(error.localizedDescription)")
            favorites = []
        }
        favoriteIDs = Set(favorites.map(\.songId))
    }

    /// Rolls back and resyncs the snapshot on failure, so the UI never shows a change that wasn't persisted.
    @discardableResult
    private func save() -> Bool {
        do {
            try context.save()
            return true
        } catch {
            logger.error("Failed to save favorites: \(error.localizedDescription)")
            context.rollback()
            reload()
            return false
        }
    }

    /// Downloads the cover once and stores it with the favorite, so the list renders artwork offline.
    private func cacheArtwork(for favorite: FavoriteSong, from url: URL) async {
        guard favorite.artworkData == nil else { return }
        do {
            let data = try await loadArtwork(url)
            // The user may have removed the favorite while the download was in flight.
            guard favorite.modelContext != nil, !favorite.isDeleted else { return }
            favorite.artworkData = data
            save()
        } catch {
            logger.notice("Artwork download failed, the remote URL stays as fallback: \(error.localizedDescription)")
        }
    }
}

extension FavoritesStore {
    static func preview(seeded: Bool = true) -> FavoritesStore {
        let store = FavoritesStore(userId: AppUser.preview.id, modelContainer: ModelContainerFactory.make(inMemory: true))
        if seeded {
            Song.previews.reversed().forEach(store.add)
        }
        return store
    }
}
