import SwiftUI

/// Password recovery sheet: asks for the email, then confirms the reset link was sent.
struct ResetPasswordView: View {

    // MARK: - Properties

    @Bindable var viewModel: AuthViewModel

    @Environment(\.dismiss) private var dismiss
    @Namespace private var glassNamespace

    private var isSent: Bool { viewModel.resetState == .sent }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // The container is what lets the glass icon morph between the two states.
            GlassEffectContainer {
                icon
            }

            VStack(spacing: Spacing.xs) {
                Text(isSent ? "Link enviado!" : "Recuperar senha")
                    .font(Typography.title)
                    .foregroundStyle(Color.textPrimary)
                Text(isSent ? sentMessage : "Enviaremos um link para você criar uma nova senha.")
                    .font(Typography.callout)
                    .foregroundStyle(Color.textSecondary)
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)

            if isSent {
                Button {
                    dismiss()
                } label: {
                    Text("Voltar ao login")
                        .font(Typography.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .controlSize(.large)
            } else {
                GlassTextField(
                    title: "E-mail",
                    text: $viewModel.resetEmail,
                    systemImage: "envelope.fill",
                    errorMessage: viewModel.resetError,
                    textContentType: .username,
                    keyboardType: .emailAddress
                )
                .submitLabel(.send)
                .onSubmit(send)

                PrimaryButton(title: "Enviar link", isLoading: viewModel.resetState == .sending, action: send)
            }
        }
        .padding(Spacing.lg)
        .padding(.top, Spacing.sm)
        .animation(.bouncy, value: viewModel.resetState)
        .sensoryFeedback(.success, trigger: isSent) { _, newValue in newValue }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Private Helpers

    /// Both states share one glass ID so the circle morphs from the key into the envelope instead of cross-fading.
    private var icon: some View {
        Image(systemName: isSent ? "envelope.open.fill" : "key.fill")
            .font(.system(size: isSent ? 44 : 34, weight: .semibold))
            .foregroundStyle(isSent ? Color.deepGreen : Color.tropicalOrange)
            .contentTransition(.symbolEffect(.replace))
            .frame(width: isSent ? 104 : 80, height: isSent ? 104 : 80)
            .glassEffect(
                .regular.tint((isSent ? Color.leafGreen : Color.pineappleYellow).opacity(0.3)),
                in: .circle
            )
            .glassEffectID("reset-icon", in: glassNamespace)
            .accessibilityHidden(true)
    }

    private var sentMessage: LocalizedStringKey {
        "Confira a caixa de entrada de **\(viewModel.resetEmail)** e siga as instruções."
    }

    private func send() {
        Task { await viewModel.sendPasswordReset() }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ResetPasswordView(viewModel: AuthViewModel(authService: InMemoryAuthService()))
        }
}
