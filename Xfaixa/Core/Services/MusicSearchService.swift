import Foundation

/// Finds songs in a music catalog.
nonisolated protocol MusicSearchService: Sendable {
    func searchSongs(matching term: String) async throws(NetworkError) -> [Song]
}

/// `MusicSearchService` backed by the iTunes Search API.
nonisolated struct ITunesSearchService: MusicSearchService {
    private let client: any APIClient

    init(client: any APIClient = URLSessionAPIClient(baseURL: .iTunesAPI)) {
        self.client = client
    }

    func searchSongs(matching term: String) async throws(NetworkError) -> [Song] {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let response = try await client.send(.songSearch(term: trimmed))
        return response.results.compactMap(Song.init(track:))
    }
}
