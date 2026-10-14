import SwiftUI

/// Account creation screen with live validation of email, password length and confirmation.
struct SignUpView: View {

    // MARK: - Properties

    @Bindable var viewModel: AuthViewModel
    let onAuthenticated: (AppUser) -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Criar conta")
                        .font(Typography.display)
                        .foregroundStyle(Color.textPrimary)
                    Text("Guarde suas músicas favoritas e ouça quando quiser.")
                        .font(Typography.callout)
                        .foregroundStyle(Color.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)

                VStack(spacing: Spacing.md) {
                    GlassTextField(
                        title: "E-mail",
                        text: $viewModel.email,
                        systemImage: "envelope.fill",
                        errorMessage: viewModel.emailError,
                        textContentType: .username,
                        keyboardType: .emailAddress
                    )
                    GlassTextField(
                        title: "Senha",
                        text: $viewModel.password,
                        systemImage: "lock.fill",
                        isSecure: true,
                        errorMessage: viewModel.passwordError,
                        textContentType: .newPassword
                    )
                    GlassTextField(
                        title: "Confirmar senha",
                        text: $viewModel.confirmPassword,
                        systemImage: "lock.rotation",
                        isSecure: true,
                        errorMessage: viewModel.confirmPasswordError,
                        textContentType: .newPassword
                    )
                    .submitLabel(.join)
                    .onSubmit(signUp)
                }

                VStack(spacing: Spacing.md) {
                    if let generalError = viewModel.generalError {
                        Label(generalError, systemImage: "exclamationmark.triangle.fill")
                            .font(Typography.footnote)
                            .foregroundStyle(Color.errorRed)
                    }

                    PrimaryButton(title: "Criar conta", isLoading: viewModel.isLoading, action: signUp)
                        .disabled(!viewModel.canSubmitSignUp)

                    HStack(spacing: Spacing.xxs) {
                        Text("Já tem uma conta?")
                            .foregroundStyle(Color.textSecondary)
                        Button("Entrar") { dismiss() }
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.deepGreen)
                            .frame(minHeight: Size.iconButton)
                            .contentShape(.rect)
                    }
                    .font(Typography.subheadline)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .background { TropicalBackground() }
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.error, trigger: viewModel.serverError) { _, newValue in newValue != nil }
        .onAppear { viewModel.switchMode(to: .signUp) }
    }

    // MARK: - Private Helpers

    private func signUp() {
        Task {
            if let user = await viewModel.signUp() {
                onAuthenticated(user)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(viewModel: AuthViewModel(authService: InMemoryAuthService()), onAuthenticated: { _ in })
    }
}
