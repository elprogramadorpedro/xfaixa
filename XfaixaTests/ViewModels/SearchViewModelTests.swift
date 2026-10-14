import Foundation
import Testing
@testable import Xfaixa

@MainActor
struct SearchViewModelTests {

    private let songs = [Song.fixture(id: 1), Song.fixture(id: 2, title: "Aquarela")]

    private func makeViewModel(
        service: MockMusicSearchService,
        isConnected: Bool = true,
        debounce: Duration = .zero
    ) -> (SearchViewModel, StaticConnectivityMonitor) {
        let connectivity = StaticConnectivityMonitor(isConnected: isConnected)
        let viewModel = SearchViewModel(searchService: service, connectivity: connectivity, debounce: debounce)
        return (viewModel, connectivity)
    }

    // MARK: - Results

    @Test func successfulSearchLoadsSongs() async {
        let service = MockMusicSearchService(result: .success(songs))
        let (viewModel, _) = makeViewModel(service: service)
        viewModel.query = "bossa"

        await viewModel.search()

        #expect(viewModel.state == .loaded(songs))
        #expect(await service.receivedTerms == ["bossa"])
    }

    @Test func searchWithoutResultsIsEmpty() async {
        let (viewModel, _) = makeViewModel(service: MockMusicSearchService(result: .success([])))
        viewModel.query = "xyzqwerty"

        await viewModel.search()

        #expect(viewModel.state == .empty)
    }

    @Test func failedSearchExposesTheError() async {
        let (viewModel, _) = makeViewModel(service: MockMusicSearchService(result: .failure(.timedOut)))
        viewModel.query = "samba"

        await viewModel.search()

        #expect(viewModel.state == .failed(.timedOut))
    }

    @Test func cancelledRequestDoesNotSurfaceAnError() async {
        let (viewModel, _) = makeViewModel(service: MockMusicSearchService(result: .failure(.cancelled)))
        viewModel.query = "samba"

        await viewModel.search()

        #expect(viewModel.state == .loading)
    }

    @Test func termIsTrimmedBeforeSearching() async {
        let service = MockMusicSearchService(result: .success(songs))
        let (viewModel, _) = makeViewModel(service: service)
        viewModel.query = "  anitta \n"

        await viewModel.search()

        #expect(await service.receivedTerms == ["anitta"])
    }

    @Test(arguments: ["", "   "])
    func blankQueryGoesBackToIdleWithoutSearching(query: String) async {
        let service = MockMusicSearchService(result: .success(songs))
        let (viewModel, _) = makeViewModel(service: service)
        viewModel.query = query

        await viewModel.search()

        #expect(viewModel.state == .idle)
        #expect(await service.receivedTerms.isEmpty)
    }

    // MARK: - Debounce

    @Test func typingCancelsTheSearchDuringTheDebounce() async {
        let service = MockMusicSearchService(result: .success(songs))
        let (viewModel, _) = makeViewModel(service: service, debounce: .seconds(5))
        viewModel.query = "bos"

        let pendingSearch = Task { await viewModel.search() }
        pendingSearch.cancel()
        await pendingSearch.value

        #expect(await service.receivedTerms.isEmpty)
        #expect(viewModel.state == .idle)
    }

    @Test func suggestionSearchesWithoutWaitingForTheDebounce() async {
        let service = MockMusicSearchService(result: .success(songs))
        let (viewModel, _) = makeViewModel(service: service, debounce: .seconds(60))

        viewModel.selectSuggestion("Samba")
        await viewModel.search()

        #expect(viewModel.query == "Samba")
        #expect(viewModel.state == .loaded(songs))
    }

    // MARK: - Connectivity

    @Test func offlineSearchFailsFastWithoutHittingTheService() async {
        let service = MockMusicSearchService(result: .success(songs))
        let (viewModel, _) = makeViewModel(service: service, isConnected: false)
        viewModel.query = "reggae"

        await viewModel.search()

        #expect(viewModel.state == .failed(.offline))
        #expect(await service.receivedTerms.isEmpty)
    }

    @Test func reconnectingRetriesASearchThatFailedOffline() async {
        let service = MockMusicSearchService(result: .success(songs))
        let (viewModel, connectivity) = makeViewModel(service: service, isConnected: false)
        viewModel.query = "reggae"
        await viewModel.search()

        connectivity.isConnected = true
        await viewModel.connectivityChanged(isConnected: true)

        #expect(viewModel.state == .loaded(songs))
    }

    @Test func reconnectingDoesNotRetryOtherFailures() async {
        let service = MockMusicSearchService(result: .failure(.httpStatus(500)))
        let (viewModel, _) = makeViewModel(service: service)
        viewModel.query = "reggae"
        await viewModel.search()

        await viewModel.connectivityChanged(isConnected: true)

        #expect(await service.receivedTerms.count == 1)
    }

    // MARK: - Retry

    @Test func retryRecoversAfterAFailure() async {
        let service = MockMusicSearchService(result: .failure(.timedOut))
        let (viewModel, _) = makeViewModel(service: service)
        viewModel.query = "mpb"
        await viewModel.search()

        await service.setResult(.success(songs))
        await viewModel.retry()

        #expect(viewModel.state == .loaded(songs))
    }
}
