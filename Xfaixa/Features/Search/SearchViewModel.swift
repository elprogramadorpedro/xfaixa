import Foundation
import Observation

/// Drives the search screen: debounces typing, runs one search at a time and exposes a single view state.
@MainActor
@Observable
final class SearchViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded([Song])
        case empty
        case failed(NetworkError)
    }

    // MARK: - Properties

    var query = ""

    private(set) var state: State = .idle

    let suggestions = ["Bossa Nova", "Anitta", "Reggae", "Samba", "Pop"]

    private let searchService: any MusicSearchService
    private let debounce: Duration
    private var skipsNextDebounce = false

    // MARK: - Init

    init(searchService: any MusicSearchService, debounce: Duration = .milliseconds(400)) {
        self.searchService = searchService
        self.debounce = debounce
    }

    // MARK: - Public API

    /// Meant to run from `.task(id: query)`: SwiftUI cancels the previous task on every keystroke,
    /// so the sleep below doubles as the debounce and stale requests never overwrite newer results.
    func search() async {
        let term = trimmedQuery
        guard !term.isEmpty else {
            state = .idle
            return
        }

        if skipsNextDebounce {
            skipsNextDebounce = false
        } else {
            do {
                try await Task.sleep(for: debounce)
            } catch {
                return
            }
        }

        await performSearch(term)
    }

    func retry() async {
        guard !trimmedQuery.isEmpty else { return }
        await performSearch(trimmedQuery)
    }

    /// A tapped suggestion is a deliberate choice, so it searches right away instead of waiting for the debounce.
    func selectSuggestion(_ suggestion: String) {
        skipsNextDebounce = true
        query = suggestion
    }

    // MARK: - Private Helpers

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func performSearch(_ term: String) async {
        state = .loading
        do {
            let songs = try await searchService.searchSongs(matching: term)
            guard !Task.isCancelled else { return }
            state = songs.isEmpty ? .empty : .loaded(songs)
        } catch .cancelled {
            // Superseded by a newer query; that task owns the state now.
        } catch {
            state = .failed(error)
        }
    }
}
