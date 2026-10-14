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

nonisolated extension Song {
    static let previews: [Song] = [
        Song(
            id: 258043468,
            title: "Garota de Ipanema",
            artist: "Antônio Carlos Jobim",
            album: "Inédito (1987)",
            artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/dc/77/db/dc77dba6-5063-7c18-4428-00a3be78b6b7/dj.ipjqpyna.jpg/600x600bb.jpg"),
            previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/09/69/7c/09697cd5-aa05-e34b-8b91-63bfbc342573/mzaf_11624938030212274213.plus.aac.p.m4a"),
            genre: "Bossa Nova",
            duration: .milliseconds(242760)
        ),
        Song(
            id: 1593185593,
            title: "Envolver",
            artist: "Anitta",
            album: "Envolver - Single",
            artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/c5/ba/2b/c5ba2b96-ff06-5f58-35ad-1c070973cee7/190296362989.jpg/600x600bb.jpg"),
            previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/2a/6f/96/2a6f96a5-b362-d87c-eadc-d477d1ed47c3/mzaf_14425900406954055410.plus.aac.p.m4a"),
            genre: "Pop",
            duration: .milliseconds(193806)
        ),
        Song(
            id: 1469575848,
            title: "Is This Love",
            artist: "Bob Marley & The Wailers",
            album: "Legend",
            artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/3c/c2/0d/3cc20dcc-8f4e-f060-36dd-7de52a7ec8fe/12UMGIM14712.rgb.jpg/600x600bb.jpg"),
            previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/57/b4/86/57b48651-318d-4e27-e486-33f4e5faaa75/mzaf_5322223461518697391.plus.aac.p.m4a"),
            genre: "Reggae",
            duration: .milliseconds(232374)
        ),
        Song(
            id: 1443845526,
            title: "Mas, Que Nada!",
            artist: "Jorge Ben Jor",
            album: "Samba Esquema Novo",
            artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/94/46/58/94465854-cafb-ec16-ce23-afbdae80d47c/06UMGIM46403.rgb.jpg/600x600bb.jpg"),
            previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/7b/6a/40/7b6a40bb-905a-f700-846e-b29a88de0d48/mzaf_11709213442413874219.plus.aac.p.m4a"),
            genre: "Samba",
            duration: .milliseconds(179293)
        ),
        Song(
            id: 1442268638,
            title: "Aquarela",
            artist: "Toquinho",
            album: "Chico e Vinícius para Crianças",
            artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/f4/cc/ad/f4ccadde-544c-8b2d-0a2f-ca2639ae2b54/13UAEIM08648.rgb.jpg/600x600bb.jpg"),
            previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/10/07/12/100712f7-ae27-433d-44e6-94a250220377/mzaf_10653737571855531726.plus.aac.p.m4a"),
            genre: "MPB",
            duration: .milliseconds(257320)
        )
    ]
}
