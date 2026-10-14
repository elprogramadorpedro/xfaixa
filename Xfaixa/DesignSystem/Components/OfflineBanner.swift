import SwiftUI

/// Floating glass capsule shown at the top of the screen while the device has no connectivity.
struct OfflineBanner: View {
    var body: some View {
        Label("Sem conexão", systemImage: "wifi.slash")
            .font(Typography.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .glassEffect(.regular.tint(Color.errorRed.opacity(0.8)), in: .capsule)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    ZStack(alignment: .top) {
        TropicalBackground()
        OfflineBanner()
            .padding(.top, Spacing.sm)
    }
}
