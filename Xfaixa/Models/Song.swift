import Foundation

/// A playable track as the app models it, independent of the catalog API's response shape.
nonisolated struct Song: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let artist: String
    let album: String?
    let artworkURL: URL?
    let previewURL: URL?
    let genre: String?
    let duration: Duration?
}

extension Song {
    static let previews: [Song] = [
        Song(
            id: 1,
            title: "Garota de Ipanema",
            artist: "Tom Jobim",
            album: "Getz/Gilberto",
            artworkURL: nil,
            previewURL: nil,
            genre: "Bossa Nova",
            duration: .seconds(320)
        ),
        Song(
            id: 2,
            title: "Envolver",
            artist: "Anitta",
            album: "Versions of Me",
            artworkURL: nil,
            previewURL: nil,
            genre: "Pop",
            duration: .seconds(193)
        ),
        Song(
            id: 3,
            title: "Is This Love",
            artist: "Bob Marley & The Wailers",
            album: "Kaya",
            artworkURL: nil,
            previewURL: nil,
            genre: "Reggae",
            duration: .seconds(232)
        )
    ]
}
