import SwiftUI

/// Now-playing bar hosted in the tab view's bottom accessory, which already renders it on Liquid Glass.
/// Collapses to a compact layout when the tab bar minimizes on scroll.
struct MiniPlayerView: View {

    // MARK: - Properties

    @Environment(PlayerService.self) private var player
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement

    private var isInline: Bool { placement == .inline }

    // MARK: - Body

    var body: some View {
        if let song = player.currentSong {
            HStack(spacing: Spacing.sm) {
                ArtworkView(url: song.artworkURL, size: isInline ? 28 : 36, cornerRadius: Radius.sm / 2)

                VStack(alignment: .leading, spacing: 0) {
                    Text(song.title)
                        .font(Typography.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)
                    if !isInline {
                        Text(song.artist)
                            .font(Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

                playPauseButton

                if !isInline {
                    Button("Fechar", systemImage: "xmark", action: player.stop)
                        .labelStyle(.iconOnly)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: Size.iconButton / 1.5, height: Size.iconButton / 1.5)
                        .contentShape(.rect)
                }
            }
            .padding(.horizontal, Spacing.sm)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text("Tocando \(song.title), de \(song.artist)"))
        }
    }

    // MARK: - Private Helpers

    /// The ring doubles as the progress bar, so the compact layout still shows how much of the preview is left.
    private var playPauseButton: some View {
        Button {
            player.togglePlayback()
        } label: {
            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                .font(.body.weight(.bold))
                .foregroundStyle(Color.tropicalOrange)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 34, height: 34)
                .overlay {
                    Circle()
                        .stroke(Color.tropicalOrange.opacity(0.2), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: player.progress)
                        .stroke(Color.tropicalOrange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.25), value: player.progress)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(player.isPlaying ? "Pausar" : "Tocar")
        .accessibilityValue(Text(player.progress, format: .percent.precision(.fractionLength(0))))
    }
}

#Preview {
    @Previewable @State var player = PlayerService()

    TabView {
        Tab("Buscar", systemImage: "magnifyingglass") {
            TropicalBackground()
        }
    }
    .tabViewBottomAccessory {
        MiniPlayerView()
    }
    .environment(player)
    .task { player.play(Song.previews[1]) }
}
