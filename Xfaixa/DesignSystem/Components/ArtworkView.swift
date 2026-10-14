import SwiftUI

/// Album artwork from locally stored data when available, otherwise loaded from a remote URL,
/// falling back to a branded gradient placeholder.
struct ArtworkView: View {
    let url: URL?
    var data: Data?
    var size: CGFloat = Size.artworkRow
    var cornerRadius: CGFloat = Radius.sm

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.25))) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        placeholder
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: cornerRadius))
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [.pineappleYellow, .tropicalOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "music.note")
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

#Preview {
    HStack(spacing: Spacing.md) {
        ArtworkView(url: nil)
        ArtworkView(url: nil, size: 96, cornerRadius: Radius.md)
    }
    .padding()
}
