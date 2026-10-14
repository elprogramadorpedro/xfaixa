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

    let authService: any AuthService

    private(set) var route: Route = .splash
    private(set) var currentUser: AppUser?

    // MARK: - Init

    init(authService: any AuthService) {
        self.authService = authService
        currentUser = authService.currentUser
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

extension RootViewModel {
    static func preview(signedIn: Bool = true) -> RootViewModel {
        RootViewModel(authService: InMemoryAuthService(latency: .zero, currentUser: signedIn ? .preview : nil))
    }
}
