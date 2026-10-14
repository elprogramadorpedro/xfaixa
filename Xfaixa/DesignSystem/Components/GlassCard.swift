import SwiftUI

/// Rounded container rendered with the system Liquid Glass material, optionally tinted with a palette color.
struct GlassCard<Content: View>: View {
    var tint: Color?
    var cornerRadius: CGFloat = Radius.lg
    var padding: CGFloat = Spacing.md
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
    }
}

#Preview {
    ZStack {
        TropicalBackground()
        VStack(spacing: Spacing.md) {
            GlassCard {
                Label("Cartão de vidro", systemImage: "sparkles")
                    .font(Typography.headline)
            }
            GlassCard(tint: .tropicalOrange.opacity(0.3)) {
                Text("Com tinte tropical")
                    .font(Typography.headline)
            }
        }
        .padding(Spacing.lg)
    }
}
