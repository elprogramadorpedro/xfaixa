import SwiftUI

@main
struct XfaixaApp: App {
    // Swapping this single dependency is all it takes to move to another auth provider.
    @State private var rootViewModel = RootViewModel(authService: InMemoryAuthService())

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: rootViewModel)
        }
    }
}
