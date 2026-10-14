import Foundation

/// Canned `MusicSearchService` for SwiftUI previews: always answers with the same result after a short delay.
nonisolated struct PreviewMusicSearchService: MusicSearchService {
    var result: Result<[Song], NetworkError> = .success(Song.previews)
    var delay: Duration = .milliseconds(300)

    func searchSongs(matching term: String) async throws(NetworkError) -> [Song] {
        try? await Task.sleep(for: delay)
        return try result.get()
    }
}
