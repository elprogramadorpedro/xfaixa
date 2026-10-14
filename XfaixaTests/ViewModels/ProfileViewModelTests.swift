import Foundation
import Testing
@testable import Xfaixa

@MainActor
struct ProfileViewModelTests {

    private let authService = MockAuthService()
    private let avatarStore = InMemoryAvatarStore()
    private let favoritesStore = FavoritesStore(
        userId: AppUser.fixture.id,
        modelContainer: ModelContainerFactory.make(inMemory: true)
    )

    private func makeViewModel() -> ProfileViewModel {
        ProfileViewModel(
            user: .fixture,
            authService: authService,
            avatarStore: avatarStore,
            favoritesStore: favoritesStore
        )
    }

    // MARK: - Avatar

    @Test func startsWithThePineappleWhenNothingWasChosen() {
        #expect(makeViewModel().fruit == .pineapple)
    }

    @Test func restoresTheFruitSavedForThisUser() {
        avatarStore.setFruit(.kiwi, for: AppUser.fixture.id)

        #expect(makeViewModel().fruit == .kiwi)
    }

    @Test func ignoresFruitsChosenByOtherUsers() {
        avatarStore.setFruit(.kiwi, for: "someone-else")

        #expect(makeViewModel().fruit == .pineapple)
    }

    @Test func selectingAFruitPersistsIt() {
        let viewModel = makeViewModel()

        viewModel.selectFruit(.watermelon)

        #expect(viewModel.fruit == .watermelon)
        #expect(avatarStore.fruit(for: AppUser.fixture.id) == .watermelon)
    }

    // MARK: - Favorites Count

    @Test func favoritesCountFollowsTheSharedStore() {
        let viewModel = makeViewModel()
        #expect(viewModel.favoritesCount == 0)

        favoritesStore.add(.fixture(id: 1))
        favoritesStore.add(.fixture(id: 2))

        #expect(viewModel.favoritesCount == 2)
    }

    // MARK: - Sign Out

    @Test func signOutSucceeds() {
        let viewModel = makeViewModel()

        #expect(viewModel.signOut())
        #expect(authService.signOutCount == 1)
        #expect(viewModel.signOutError == nil)
    }

    @Test func signOutFailureKeepsTheSessionAndExplainsWhy() {
        authService.signOutError = .networkUnavailable
        let viewModel = makeViewModel()

        #expect(viewModel.signOut() == false)
        #expect(viewModel.signOutError == AuthError.networkUnavailable.message)
    }
}
