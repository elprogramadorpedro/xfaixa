import Foundation

/// Raw payload of the iTunes Search API. Every field is optional because the catalog mixes result kinds.
nonisolated struct ITunesSearchResponse: Decodable, Sendable {
    let resultCount: Int
    let results: [ITunesTrack]
}

nonisolated struct ITunesTrack: Decodable, Sendable {
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let artworkUrl100: URL?
    let previewUrl: URL?
    let primaryGenreName: String?
    let trackTimeMillis: Int?
}

extension Song {
    /// Returns nil for results that aren't usable as songs, such as entries without an id or title.
    nonisolated init?(track: ITunesTrack) {
        guard let id = track.trackId, let title = track.trackName, let artist = track.artistName else {
            return nil
        }
        self.init(
            id: id,
            title: title,
            artist: artist,
            album: track.collectionName,
            artworkURL: track.artworkUrl100.map(Self.highResolutionArtwork),
            previewURL: track.previewUrl,
            genre: track.primaryGenreName,
            duration: track.trackTimeMillis.map { .milliseconds($0) }
        )
    }

    /// The API only advertises 100px artwork, but the CDN serves any size when the dimensions in the path change.
    nonisolated static func highResolutionArtwork(from url: URL) -> URL {
        URL(string: url.absoluteString.replacingOccurrences(of: "100x100bb", with: "600x600bb")) ?? url
    }
}
