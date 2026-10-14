import SwiftUI

/// Capsule-shaped glass button used for quick suggestions and filters.
struct ChipButton: View {
    let title: String
    var systemImage: String?
    var tint: Color?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(Typography.subheadline.weight(.semibold))
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, Spacing.xxs)
        }
        .buttonStyle(.glass)
        .tint(tint)
    }
}

#Preview {
    let suggestions: [(String, Color)] = [
        ("Bossa Nova", .tropicalOrange), ("Anitta", .pineappleYellow), ("Reggae", .leafGreen),
        ("Samba", .tropicalOrange), ("Pop", .pineappleYellow)
    ]

    ZStack {
        TropicalBackground()
        // Sharing one container lets neighbouring chips blend and morph as a single glass layer.
        GlassEffectContainer(spacing: Spacing.xs) {
            FlowLayout {
                ForEach(suggestions, id: \.0) { title, tint in
                    ChipButton(title: title, systemImage: "music.note", tint: tint.opacity(0.35)) {}
                }
            }
        }
        .padding(Spacing.lg)
    }
}
