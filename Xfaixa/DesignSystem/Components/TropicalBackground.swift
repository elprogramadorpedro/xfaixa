import SwiftUI

/// Full-screen tropical mesh gradient that gives the Liquid Glass layers living content to refract.
struct TropicalBackground: View {

    // MARK: - Properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body

    var body: some View {
        // 30 fps is plenty for a drift this slow and halves the redraw cost of every glass layer above it.
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion)) { context in
            MeshGradient(
                width: 3,
                height: 3,
                points: points(at: reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate),
                colors: colors
            )
        }
        .background(Color.appBackground)
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: - Private Helpers

    private var colors: [Color] {
        // Dark mode needs stronger accents to stay vivid against the near-black green base.
        let intensity = colorScheme == .dark ? 1.4 : 1.0
        return [
            .pineappleYellow.opacity(0.45 * intensity), .appBackground, .tropicalOrange.opacity(0.40 * intensity),
            .appBackground, .tropicalOrange.opacity(0.18 * intensity), .appBackground,
            .leafGreen.opacity(0.35 * intensity), .pineappleYellow.opacity(0.22 * intensity), .leafGreen.opacity(0.28 * intensity)
        ]
    }

    /// Only the inner points move; the corners and edges stay pinned so the mesh always covers the screen.
    private func points(at time: TimeInterval) -> [SIMD2<Float>] {
        let drift = Float(sin(time * 0.35)) * 0.08
        let sway = Float(cos(time * 0.25)) * 0.06
        return [
            [0, 0], [0.5 + sway, 0], [1, 0],
            [0, 0.5 + drift], [0.5 + drift, 0.5 - sway], [1, 0.5 - drift],
            [0, 1], [0.5 - sway, 1], [1, 1]
        ]
    }
}

#Preview {
    TropicalBackground()
}
