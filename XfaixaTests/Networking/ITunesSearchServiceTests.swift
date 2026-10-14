import Foundation
import Testing
@testable import Xfaixa

struct ITunesSearchServiceTests {

    private static let payload = Data("""
    {
      "resultCount": 3,
      "results": [
        {
          "trackId": 1440857781,
          "trackName": "Garota de Ipanema",
          "artistName": "Tom Jobim",
          "collectionName": "Getz/Gilberto",
          "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music/v4/ab/cd/source/100x100bb.jpg",
          "previewUrl": "https://audio-ssl.itunes.apple.com/preview.m4a",
          "primaryGenreName": "Bossa Nova",
          "trackTimeMillis": 320000
        },
        {
          "trackName": "Entry without an id",
          "artistName": "Unknown"
        },
        {
          "trackId": 42,
          "trackName": "Envolver",
          "artistName": "Anitta"
        }
      ]
    }
    """.utf8)

    @Test func mapsCompleteTracksAndSkipsIncompleteOnes() async throws {
        let service = ITunesSearchService(client: StubAPIClient(result: .success(Self.payload)))

        let songs = try await service.searchSongs(matching: "bossa")

        #expect(songs.map(\.id) == [1440857781, 42])
        let first = try #require(songs.first)
        #expect(first.title == "Garota de Ipanema")
        #expect(first.artist == "Tom Jobim")
        #expect(first.album == "Getz/Gilberto")
        #expect(first.duration == .seconds(320))
        #expect(songs.last?.artworkURL == nil)
    }

    @Test func requestsHighResolutionArtwork() async throws {
        let service = ITunesSearchService(client: StubAPIClient(result: .success(Self.payload)))

        let songs = try await service.searchSongs(matching: "bossa")

        #expect(songs.first?.artworkURL?.lastPathComponent == "600x600bb.jpg")
    }

    @Test func blankTermReturnsNoSongsWithoutHittingTheNetwork() async throws {
        let service = ITunesSearchService(client: StubAPIClient(result: .failure(.unknown)))

        let songs = try await service.searchSongs(matching: "   ")

        #expect(songs.isEmpty)
    }

    @Test func propagatesNetworkErrors() async {
        let service = ITunesSearchService(client: StubAPIClient(result: .failure(.offline)))

        await #expect(throws: NetworkError.offline) {
            try await service.searchSongs(matching: "samba")
        }
    }

    @Test func reportsMalformedPayloadAsDecodingError() async {
        let service = ITunesSearchService(client: StubAPIClient(result: .success(Data("{}".utf8))))

        await #expect(throws: NetworkError.decoding) {
            try await service.searchSongs(matching: "samba")
        }
    }
}
