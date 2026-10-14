import Foundation
import SwiftData
import Testing
@testable import Xfaixa

@MainActor
struct FavoritesStoreTests {

    private let container = ModelContainerFactory.make(inMemory: true)

    private func makeStore(userId: String = AppUser.fixture.id) -> FavoritesStore {
        FavoritesStore(userId: userId, modelContainer: container)
    }

    @Test func addingAndRemovingUpdatesTheSnapshot() {
        let store = makeStore()
        let song = Song.fixture(id: 7)

        store.add(song)
        #expect(store.isFavorite(song))
        #expect(store.count == 1)

        store.remove(songId: song.id)
        #expect(store.isFavorite(song) == false)
        #expect(store.favorites.isEmpty)
    }

    @Test func toggleFlipsTheFavoriteState() {
        let store = makeStore()
        let song = Song.fixture(id: 7)

        store.toggle(song)
        #expect(store.isFavorite(song))

        store.toggle(song)
        #expect(store.isFavorite(song) == false)
    }

    @Test func addingTheSameSongTwiceKeepsASingleFavorite() {
        let store = makeStore()

        store.add(.fixture(id: 7))
        store.add(.fixture(id: 7))

        #expect(store.count == 1)
    }

    @Test func newestFavoritesComeFirst() {
        let store = makeStore()

        store.add(.fixture(id: 1))
        store.add(.fixture(id: 2))

        #expect(store.favorites.map(\.songId) == [2, 1])
    }

    @Test func favoritesPersistAcrossStoreInstances() {
        makeStore().add(.fixture(id: 3, title: "Aquarela"))

        let reloaded = makeStore()

        #expect(reloaded.favorites.map(\.title) == ["Aquarela"])
    }

    @Test func favoritesAreScopedToTheirUser() {
        makeStore(userId: "ana").add(.fixture(id: 1))

        #expect(makeStore(userId: "bia").favorites.isEmpty)
    }

    @Test func storedFavoriteRebuildsTheOriginalSong() throws {
        let store = makeStore()
        let song = Song.fixture(id: 9)

        store.add(song)

        #expect(try #require(store.favorites.first).song == song)
    }
}
