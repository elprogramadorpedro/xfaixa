import SwiftUI

/// Text input on a Liquid Glass surface with a leading icon, optional secure entry and an inline error message.
struct GlassTextField: View {

    // MARK: - Properties

    let title: LocalizedStringKey
    @Binding var text: String
    let systemImage: String
    var isSecure = false
    var errorMessage: String?
    var textContentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: systemImage)
                    .font(Typography.bodyEmphasized)
                    .foregroundStyle(hasError ? Color.errorRed : Color.deepGreen)
                    .frame(minWidth: Spacing.lg)
                    .accessibilityHidden(true)

                input
                    .font(Typography.body)
                    .foregroundStyle(Color.textPrimary)
                    .focused($isFocused)
                    .textContentType(textContentType)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                if isSecure {
                    revealButton
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .frame(minHeight: 52)
            .glassEffect(.regular.tint(focusTint).interactive(), in: .rect(cornerRadius: Radius.md))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(Color.errorRed, lineWidth: hasError ? 1.5 : 0)
            }
            .contentShape(.rect(cornerRadius: Radius.md))
            .onTapGesture { isFocused = true }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(Typography.footnote)
                    .foregroundStyle(Color.errorRed)
                    .padding(.horizontal, Spacing.xs)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.snappy, value: errorMessage)
        .animation(.easeOut(duration: 0.2), value: isFocused)
    }

    // MARK: - Private Helpers

    private var hasError: Bool { errorMessage != nil }

    private var focusTint: Color? {
        isFocused ? Color.tropicalOrange.opacity(0.12) : nil
    }

    @ViewBuilder
    private var input: some View {
        if isSecure && !isRevealed {
            SecureField(title, text: $text)
        } else {
            TextField(title, text: $text)
        }
    }

    private var revealButton: some View {
        Button {
            isRevealed.toggle()
            // Swapping SecureField for TextField drops focus, so restore it to keep the keyboard up.
            isFocused = true
        } label: {
            Image(systemName: isRevealed ? "eye.slash" : "eye")
                .foregroundStyle(Color.textSecondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRevealed ? "Ocultar senha" : "Mostrar senha")
    }
}

#Preview {
    @Previewable @State var email = "ana@xfaixa.app"
    @Previewable @State var password = ""

    ZStack {
        TropicalBackground()
        VStack(spacing: Spacing.md) {
            GlassTextField(title: "E-mail", text: $email, systemImage: "envelope.fill", keyboardType: .emailAddress)
            GlassTextField(
                title: "Senha",
                text: $password,
                systemImage: "lock.fill",
                isSecure: true,
                errorMessage: "A senha precisa ter pelo menos 6 caracteres"
            )
        }
        .padding(Spacing.lg)
    }
}
