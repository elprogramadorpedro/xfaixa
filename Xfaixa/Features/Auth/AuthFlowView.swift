import SwiftUI

/// Entry point of the signed-out experience.
struct AuthFlowView: View {
    let onAuthenticated: (AppUser) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Spacer()
                PineappleView(size: 96, isSwaying: true)
                VStack(spacing: Spacing.xs) {
                    Text("Bem-vindo ao Xfaixa")
                        .font(Typography.title)
                        .foregroundStyle(Color.textPrimary)
                    Text("Descubra músicas e guarde suas favoritas.")
                        .font(Typography.body)
                        .foregroundStyle(Color.textSecondary)
                }
                .multilineTextAlignment(.center)
                Spacer()
                PrimaryButton(title: "Entrar") {
                    onAuthenticated(.preview)
                }
            }
            .padding(Spacing.lg)
            .background { TropicalBackground() }
        }
    }
}

#Preview {
    AuthFlowView { _ in }
}
