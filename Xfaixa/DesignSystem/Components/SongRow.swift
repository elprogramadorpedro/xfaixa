import SwiftUI

/// List row for a track: artwork, title, artist and the favorite and play controls.
/// Takes plain values instead of a model so the design system stays independent from features.
struct SongRow: View {

    // MARK: - Properties

    let title: String
    let artist: String
    let artworkURL: URL?
    var artworkData: Data?
    var isFavorite = false
    var isPlaying = false
    let onToggleFavorite: () -> Void
    let onTogglePlay: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Body

    var body: some View {
        Group {
            // At accessibility sizes the text gets its own line; squeezed next to the controls it would truncate to a few letters.
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.sm) {
                        ArtworkView(url: artworkURL, data: artworkData)
                        Spacer()
                        favoriteButton
                        playButton
                    }
                    details(lineLimit: 3)
                }
            } else {
                HStack(spacing: Spacing.sm) {
                    ArtworkView(url: artworkURL, data: artworkData)
                    details(lineLimit: 1)
                    favoriteButton
                    playButton
                }
            }
        }
        .padding(Spacing.sm)
        // Rows are content, not controls: a translucent surface keeps glass reserved for the floating layer.
        .background(Color.surface.opacity(0.72), in: .rect(cornerRadius: Radius.lg))
    }

    // MARK: - Private Helpers

    private func details(lineLimit: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(Typography.headline)
                .foregroundStyle(Color.textPrimary)
            Text(artist)
                .font(Typography.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
        .lineLimit(lineLimit)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var favoriteButton: some View {
        Button(action: onToggleFavorite) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundStyle(isFavorite ? Color.tropicalOrange : Color.textSecondary)
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, value: isFavorite)
                .frame(width: Size.iconButton, height: Size.iconButton)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remover dos favoritos" : "Adicionar aos favoritos")
    }

    private var playButton: some View {
        Button(action: onTogglePlay) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.body.weight(.bold))
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .tint(.tropicalOrange)
        .accessibilityLabel(isPlaying ? "Pausar prévia" : "Tocar prévia")
    }
}

#Preview {
    @Previewable @State var isFavorite = true
    @Previewable @State var isPlaying = false

    ZStack {
        TropicalBackground()
        VStack(spacing: Spacing.sm) {
            SongRow(
                title: "Garota de Ipanema",
                artist: "Tom Jobim",
                artworkURL: nil,
                isFavorite: isFavorite,
                isPlaying: isPlaying,
                onToggleFavorite: { isFavorite.toggle() },
                onTogglePlay: { isPlaying.toggle() }
            )
            SongRow(
                title: "Envolver",
                artist: "Anitta",
                artworkURL: nil,
                onToggleFavorite: {},
                onTogglePlay: {}
            )
        }
        .padding(Spacing.md)
    }
}
