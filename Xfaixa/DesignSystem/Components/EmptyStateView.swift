import SwiftUI

/// Centered placeholder for empty, error and onboarding states, with an optional call to action.
struct EmptyStateView<Illustration: View>: View {

    // MARK: - Properties

    private let title: LocalizedStringKey
    private let message: LocalizedStringKey
    private let actionTitle: LocalizedStringKey?
    private let action: (() -> Void)?
    private let illustration: Illustration

    // MARK: - Init

    init(
        _ title: LocalizedStringKey,
        message: LocalizedStringKey,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder illustration: () -> Illustration
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.illustration = illustration()
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.lg) {
            illustration
                .accessibilityHidden(true)

            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.title)
                    .foregroundStyle(Color.textPrimary)
                Text(message)
                    .font(Typography.body)
                    .foregroundStyle(Color.textSecondary)
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(Typography.headline)
                    .buttonStyle(.glassProminent)
                    .tint(.tropicalOrange)
                    .controlSize(.large)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SF Symbol Illustration

extension EmptyStateView where Illustration == SymbolIllustration {
    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        message: LocalizedStringKey,
        actionTitle: LocalizedStringKey? = nil,
        action: (() -> Void)? = nil
    ) {
        self.init(title, message: message, actionTitle: actionTitle, action: action) {
            SymbolIllustration(systemImage: systemImage)
        }
    }
}

/// SF Symbol sitting on a tinted glass circle, used as the default empty state artwork.
struct SymbolIllustration: View {
    let systemImage: String

    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize: CGFloat = 48

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: symbolSize, weight: .semibold))
            .foregroundStyle(Color.tropicalOrange.gradient)
            .padding(Spacing.lg)
            .glassEffect(.regular.tint(Color.pineappleYellow.opacity(0.25)), in: .circle)
    }
}

#Preview("Empty") {
    ZStack {
        TropicalBackground()
        EmptyStateView("Nada encontrado", systemImage: "magnifyingglass", message: "Tente buscar por outro artista ou música.")
    }
}

#Preview("Error") {
    ZStack {
        TropicalBackground()
        EmptyStateView(
            "Algo deu errado",
            systemImage: "exclamationmark.triangle.fill",
            message: "Não foi possível carregar as músicas.",
            actionTitle: "Tentar novamente",
            action: {}
        )
    }
}
