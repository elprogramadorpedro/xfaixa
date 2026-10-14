import Observation

/// Owns the top-level route: the splash plays first, then the session decides between auth and the main app.
@MainActor
@Observable
final class RootViewModel {

    enum Route: Hashable {
        case splash
        case auth
        case main
    }

    // MARK: - Properties

    private(set) var route: Route = .splash
    private(set) var currentUser: AppUser?

    // MARK: - Init

    init(currentUser: AppUser? = nil) {
        self.currentUser = currentUser
    }

    // MARK: - Public API

    func splashDidFinish() {
        route = currentUser == nil ? .auth : .main
    }

    func didAuthenticate(as user: AppUser) {
        currentUser = user
        route = .main
    }

    func didSignOut() {
        currentUser = nil
        route = .auth
    }
}
