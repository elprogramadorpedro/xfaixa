import Foundation

/// Composition root: the concrete services the app runs with, created once and handed down to features.
@MainActor
struct AppDependencies {
    let authService: any AuthService
    let searchService: any MusicSearchService

    static func live() -> AppDependencies {
        AppDependencies(
            authService: InMemoryAuthService(),
            searchService: ITunesSearchService()
        )
    }

    static func preview(signedInAs user: AppUser? = .preview) -> AppDependencies {
        AppDependencies(
            authService: InMemoryAuthService(latency: .zero, currentUser: user),
            searchService: PreviewMusicSearchService()
        )
    }
}
