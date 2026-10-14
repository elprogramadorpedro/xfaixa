import SwiftUI

@main
struct XfaixaApp: App {
    // Every concrete service is chosen in AppDependencies.live(), so swapping a backend touches a single place.
    @State private var rootViewModel = RootViewModel(dependencies: .live())

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: rootViewModel)
        }
    }
}
