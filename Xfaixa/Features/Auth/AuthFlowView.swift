import SwiftUI

/// Signed-out experience: login as the root, sign up pushed on top and password recovery as a sheet.
struct AuthFlowView: View {

    private enum Destination: Hashable {
        case signUp
    }

    // MARK: - Properties

    let onAuthenticated: (AppUser) -> Void

    @State private var viewModel: AuthViewModel
    @State private var path: [Destination] = []
    @State private var isShowingPasswordReset = false

    // MARK: - Init

    init(authService: any AuthService, onAuthenticated: @escaping (AppUser) -> Void) {
        self.onAuthenticated = onAuthenticated
        _viewModel = State(initialValue: AuthViewModel(authService: authService))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $path) {
            LoginView(
                viewModel: viewModel,
                onCreateAccount: { path.append(.signUp) },
                onForgotPassword: {
                    viewModel.prepareReset()
                    isShowingPasswordReset = true
                },
                onAuthenticated: onAuthenticated
            )
            .navigationDestination(for: Destination.self) { _ in
                SignUpView(viewModel: viewModel, onAuthenticated: onAuthenticated)
            }
        }
        .tint(.deepGreen)
        .sheet(isPresented: $isShowingPasswordReset) {
            ResetPasswordView(viewModel: viewModel)
        }
    }
}

#Preview {
    AuthFlowView(authService: InMemoryAuthService()) { _ in }
}
