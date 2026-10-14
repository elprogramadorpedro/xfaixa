import Observation

/// Owns the top-level route: the splash plays first, then the session decides between auth and the main app.
@MainActor
@Observable
final class RootViewModel {

    enum Route: Hashable {
        case splash
        case auth
        case main(AppUser)
    }

    // MARK: - Properties

    let dependencies: AppDependencies

    private(set) var route: Route = .splash
    private(set) var currentUser: AppUser?

    // MARK: - Init

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        currentUser = dependencies.authService.currentUser
    }

    // MARK: - Public API

    func splashDidFinish() {
        route = currentUser.map(Route.main) ?? .auth
    }

    func didAuthenticate(as user: AppUser) {
        currentUser = user
        route = .main(user)
    }

    func didSignOut() {
        currentUser = nil
        route = .auth
    }
}

extension RootViewModel {
    static func preview(signedIn: Bool = true) -> RootViewModel {
        RootViewModel(dependencies: .preview(signedInAs: signedIn ? .preview : nil))
    }
}
