import Foundation
@testable import Xfaixa

/// Records every term it is asked for and answers with a configurable result.
actor MockMusicSearchService: MusicSearchService {
    private(set) var receivedTerms: [String] = []
    private var result: Result<[Song], NetworkError>

    init(result: Result<[Song], NetworkError> = .success([])) {
        self.result = result
    }

    func setResult(_ result: Result<[Song], NetworkError>) {
        self.result = result
    }

    func searchSongs(matching term: String) async throws(NetworkError) -> [Song] {
        receivedTerms.append(term)
        return try result.get()
    }
}
