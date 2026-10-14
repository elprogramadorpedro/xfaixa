import Foundation
import SwiftData

/// A song saved by a specific user. Everything needed to render it, artwork included,
/// lives in the local store so favorites keep working offline.
@Model
final class FavoriteSong {
    #Unique<FavoriteSong>([\.userId, \.songId])
    #Index<FavoriteSong>([\.userId, \.addedAt])

    var userId: String
    var songId: Int
    var title: String
    var artist: String
    var album: String?
    var artworkURL: URL?
    var previewURL: URL?
    var genre: String?
    var durationSeconds: Double?
    var addedAt: Date
    @Attribute(.externalStorage) var artworkData: Data?

    init(song: Song, userId: String, addedAt: Date = .now) {
        self.userId = userId
        songId = song.id
        title = song.title
        artist = song.artist
        album = song.album
        artworkURL = song.artworkURL
        previewURL = song.previewURL
        genre = song.genre
        durationSeconds = song.duration.map { Double($0.components.seconds) + Double($0.components.attoseconds) / 1e18 }
        self.addedAt = addedAt
    }

    var song: Song {
        Song(
            id: songId,
            title: title,
            artist: artist,
            album: album,
            artworkURL: artworkURL,
            previewURL: previewURL,
            genre: genre,
            duration: durationSeconds.map { .seconds($0) }
        )
    }
}
