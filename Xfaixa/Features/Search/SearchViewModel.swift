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
    private let connectivity: any ConnectivityMonitoring
    private let debounce: Duration
    private var skipsNextDebounce = false

    // MARK: - Init

    init(
        searchService: any MusicSearchService,
        connectivity: any ConnectivityMonitoring,
        debounce: Duration = .milliseconds(400)
    ) {
        self.searchService = searchService
        self.connectivity = connectivity
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

    /// Re-runs a search that failed only because the device was offline, as soon as the connection is back.
    func connectivityChanged(isConnected: Bool) async {
        guard isConnected, state == .failed(.offline) else { return }
        await retry()
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
        // Failing fast avoids waiting for URLSession to time out when the path is known to be down.
        guard connectivity.isConnected else {
            state = .failed(.offline)
            return
        }

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
