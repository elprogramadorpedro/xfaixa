import Foundation
import Observation

/// State for the profile tab: the user's fruit avatar, favorites count and sign out.
@MainActor
@Observable
final class ProfileViewModel {

    // MARK: - Properties

    let user: AppUser

    var isPickingFruit = false
    var isConfirmingSignOut = false

    private(set) var fruit: Fruit
    private(set) var signOutError: String?

    private let authService: any AuthService
    private let avatarStore: any AvatarStore
    private let favoritesStore: FavoritesStore

    // MARK: - Init

    init(user: AppUser, authService: any AuthService, avatarStore: any AvatarStore, favoritesStore: FavoritesStore) {
        self.user = user
        self.authService = authService
        self.avatarStore = avatarStore
        self.favoritesStore = favoritesStore
        fruit = avatarStore.fruit(for: user.id) ?? .default
    }

    // MARK: - Public API

    var favoritesCount: Int { favoritesStore.count }

    func selectFruit(_ newFruit: Fruit) {
        guard newFruit != fruit else { return }
        fruit = newFruit
        avatarStore.setFruit(newFruit, for: user.id)
    }

    /// Returns whether the session ended, so the caller can leave the signed-in flow.
    func signOut() -> Bool {
        do {
            try authService.signOut()
            signOutError = nil
            return true
        } catch {
            signOutError = error.message
            return false
        }
    }
}
