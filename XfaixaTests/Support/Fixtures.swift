import Foundation
@testable import Xfaixa

extension AppUser {
    static let fixture = AppUser(id: "user-1", email: "ana@xfaixa.app")
}

extension Song {
    static func fixture(id: Int, title: String = "Garota de Ipanema") -> Song {
        Song(
            id: id,
            title: title,
            artist: "Tom Jobim",
            album: nil,
            artworkURL: nil,
            previewURL: nil,
            genre: "Bossa Nova",
            duration: .seconds(30)
        )
    }
}
