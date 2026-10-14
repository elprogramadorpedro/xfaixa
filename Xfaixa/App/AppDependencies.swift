import Foundation
import SwiftData

/// Composition root: the concrete services the app runs with, created once and handed down to features.
@MainActor
struct AppDependencies {
    let authService: any AuthService
    let searchService: any MusicSearchService
    let modelContainer: ModelContainer
    let avatarStore: any AvatarStore
    let connectivity: any ConnectivityMonitoring

    static func live() -> AppDependencies {
        AppDependencies(
            authService: InMemoryAuthService(),
            searchService: ITunesSearchService(),
            modelContainer: ModelContainerFactory.make(),
            avatarStore: UserDefaultsAvatarStore(),
            connectivity: NetworkMonitor()
        )
    }

    static func preview(signedInAs user: AppUser? = .preview, isConnected: Bool = true) -> AppDependencies {
        AppDependencies(
            authService: InMemoryAuthService(latency: .zero, currentUser: user),
            searchService: PreviewMusicSearchService(),
            modelContainer: ModelContainerFactory.make(inMemory: true),
            avatarStore: InMemoryAvatarStore(),
            connectivity: StaticConnectivityMonitor(isConnected: isConnected)
        )
    }
}
