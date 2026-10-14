import SwiftUI

/// Top-level container that swaps between the splash, the auth flow and the main app.
struct RootView: View {
    @State private var viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // The splash is a brand moment; connectivity only matters once the user can act on it.
    private var isShowingOfflineBanner: Bool {
        !viewModel.dependencies.connectivity.isConnected && viewModel.route != .splash
    }

    var body: some View {
        ZStack {
            switch viewModel.route {
            case .splash:
                SplashView(onFinished: viewModel.splashDidFinish)
                    .transition(.opacity.combined(with: .scale(scale: 1.08)))
            case .auth:
                AuthFlowView(authService: viewModel.dependencies.authService, onAuthenticated: viewModel.didAuthenticate(as:))
                    .transition(.opacity)
            case .main(let user):
                MainTabView(dependencies: viewModel.dependencies, user: user)
                    .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.5), value: viewModel.route)
        .overlay(alignment: .top) {
            if isShowingOfflineBanner {
                OfflineBanner()
                    .padding(.top, Spacing.xs)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.45, bounce: 0.3), value: isShowingOfflineBanner)
        .onChange(of: viewModel.dependencies.connectivity.isConnected) { _, isConnected in
            AccessibilityNotification.Announcement(isConnected ? "Conexão restabelecida" : "Sem conexão").post()
        }
        .environment(viewModel)
    }
}

#Preview("Signed out") {
    RootView(viewModel: .preview(signedIn: false))
}

#Preview("Signed in") {
    RootView(viewModel: .preview())
}

#Preview("Offline") {
    RootView(viewModel: RootViewModel(dependencies: .preview(isConnected: false)))
}
