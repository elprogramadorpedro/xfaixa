import SwiftUI

/// Full-width call to action using the prominent glass style tinted with the brand orange.
struct PrimaryButton: View {
    let title: LocalizedStringKey
    var systemImage: String?
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            label
                .opacity(isLoading ? 0 : 1)
                // Overlaying the spinner keeps the button height driven by the label, so it never jumps.
                .overlay {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
            .font(Typography.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xxs)
        }
        .buttonStyle(.glassProminent)
        .tint(.tropicalOrange)
        .controlSize(.large)
        // Blocking hits instead of using .disabled keeps the orange tint visible while the request runs.
        .allowsHitTesting(!isLoading)
        .accessibilityValue(isLoading ? Text("Carregando") : Text(""))
    }

    @ViewBuilder
    private var label: some View {
        if let systemImage {
            Label(title, systemImage: systemImage)
        } else {
            Text(title)
        }
    }
}

#Preview {
    ZStack {
        TropicalBackground()
        VStack(spacing: Spacing.md) {
            PrimaryButton(title: "Entrar") {}
            PrimaryButton(title: "Entrar", isLoading: true) {}
            PrimaryButton(title: "Criar conta", systemImage: "person.badge.plus") {}
                .disabled(true)
        }
        .padding(Spacing.lg)
    }
}
