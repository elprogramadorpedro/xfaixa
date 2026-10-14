import SwiftUI

/// Top-level container that swaps between the splash, the auth flow and the main app.
struct RootView: View {
    @State private var viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            switch viewModel.route {
            case .splash:
                SplashView(onFinished: viewModel.splashDidFinish)
                    .transition(.opacity.combined(with: .scale(scale: 1.08)))
            case .auth:
                AuthFlowView(authService: viewModel.authService, onAuthenticated: viewModel.didAuthenticate(as:))
                    .transition(.opacity)
            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.5), value: viewModel.route)
        .environment(viewModel)
    }
}

#Preview("Signed out") {
    RootView(viewModel: .preview(signedIn: false))
}

#Preview("Signed in") {
    RootView(viewModel: .preview())
}
