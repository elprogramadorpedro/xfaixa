import SwiftUI

/// Sign in screen with links to account creation and password recovery.
struct LoginView: View {

    // MARK: - Properties

    @Bindable var viewModel: AuthViewModel
    let onCreateAccount: () -> Void
    let onForgotPassword: () -> Void
    let onAuthenticated: (AppUser) -> Void

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                header

                VStack(alignment: .trailing, spacing: Spacing.sm) {
                    VStack(spacing: Spacing.md) {
                        GlassTextField(
                            title: "E-mail",
                            text: $viewModel.email,
                            systemImage: "envelope.fill",
                            errorMessage: viewModel.emailError,
                            textContentType: .username,
                            keyboardType: .emailAddress
                        )
                        .submitLabel(.next)

                        GlassTextField(
                            title: "Senha",
                            text: $viewModel.password,
                            systemImage: "lock.fill",
                            isSecure: true,
                            errorMessage: viewModel.passwordError,
                            textContentType: .password
                        )
                        .submitLabel(.go)
                        .onSubmit(signIn)
                    }

                    Button("Esqueci minha senha", action: onForgotPassword)
                        .font(Typography.subheadline.weight(.semibold))
                        .foregroundStyle(Color.deepGreen)
                }

                VStack(spacing: Spacing.md) {
                    if let generalError = viewModel.generalError {
                        Label(generalError, systemImage: "exclamationmark.triangle.fill")
                            .font(Typography.footnote)
                            .foregroundStyle(Color.errorRed)
                            .multilineTextAlignment(.center)
                    }

                    PrimaryButton(title: "Entrar", isLoading: viewModel.isLoading, action: signIn)

                    HStack(spacing: Spacing.xxs) {
                        Text("Não tem uma conta?")
                            .foregroundStyle(Color.textSecondary)
                        Button("Criar conta", action: onCreateAccount)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.deepGreen)
                    }
                    .font(Typography.subheadline)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.xxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background { TropicalBackground() }
        .toolbar(.hidden, for: .navigationBar)
        .sensoryFeedback(.error, trigger: viewModel.serverError) { _, newValue in newValue != nil }
        .onAppear { viewModel.switchMode(to: .signIn) }
    }

    // MARK: - Private Helpers

    private var header: some View {
        VStack(spacing: Spacing.sm) {
            PineappleView(size: 76, isSwaying: true)
            Text("Xfaixa")
                .font(Typography.display)
                .foregroundStyle(Color.textPrimary)
            Text("Sua trilha sonora tropical")
                .font(Typography.callout)
                .foregroundStyle(Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private func signIn() {
        Task {
            if let user = await viewModel.signIn() {
                onAuthenticated(user)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView(
            viewModel: AuthViewModel(authService: InMemoryAuthService()),
            onCreateAccount: {},
            onForgotPassword: {},
            onAuthenticated: { _ in }
        )
    }
}
