import Foundation
import SwiftData

/// Composition root: the concrete services the app runs with, created once and handed down to features.
@MainActor
struct AppDependencies {
    let authService: any AuthService
    let searchService: any MusicSearchService
    let modelContainer: ModelContainer
    let avatarStore: any AvatarStore

    static func live() -> AppDependencies {
        AppDependencies(
            authService: InMemoryAuthService(),
            searchService: ITunesSearchService(),
            modelContainer: ModelContainerFactory.make(),
            avatarStore: UserDefaultsAvatarStore()
        )
    }

    static func preview(signedInAs user: AppUser? = .preview) -> AppDependencies {
        AppDependencies(
            authService: InMemoryAuthService(latency: .zero, currentUser: user),
            searchService: PreviewMusicSearchService(),
            modelContainer: ModelContainerFactory.make(inMemory: true),
            avatarStore: InMemoryAvatarStore()
        )
    }
}
