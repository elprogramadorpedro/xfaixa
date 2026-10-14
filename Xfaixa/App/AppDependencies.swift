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
    let player: PlayerService

    /// Launch argument UI tests pass so they run against the in-memory backend instead of real Firebase accounts.
    static let uiTestingArgument = "-ui-testing"

    static func live(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppDependencies {
        // A fresh clone has no GoogleService-Info.plist; falling back to the demo backend keeps it runnable instead of crashing.
        let hasFirebaseConfig = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil
        let usesFirebase = hasFirebaseConfig && !arguments.contains(uiTestingArgument)

        return AppDependencies(
            authService: usesFirebase ? FirebaseAuthService() : InMemoryAuthService(),
            searchService: ITunesSearchService(),
            modelContainer: ModelContainerFactory.make(),
            avatarStore: UserDefaultsAvatarStore(),
            connectivity: NetworkMonitor(),
            player: PlayerService()
        )
    }

    static func preview(signedInAs user: AppUser? = .preview, isConnected: Bool = true) -> AppDependencies {
        AppDependencies(
            authService: InMemoryAuthService(latency: .zero, currentUser: user),
            searchService: PreviewMusicSearchService(),
            modelContainer: ModelContainerFactory.make(inMemory: true),
            avatarStore: InMemoryAvatarStore(),
            connectivity: StaticConnectivityMonitor(isConnected: isConnected),
            player: PlayerService()
        )
    }
}
