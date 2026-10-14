import SwiftUI

/// Animated brand intro shown once per launch before the app decides between auth and the main flow.
struct SplashView: View {

    // MARK: - Properties

    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    private let duration: Duration = .seconds(1.8)

    // MARK: - Body

    var body: some View {
        ZStack {
            TropicalBackground()

            VStack(spacing: Spacing.lg) {
                ZStack {
                    PineappleView(size: 150, isSwaying: true)
                    if !reduceMotion {
                        sweatDrops
                    }
                }
                .scaleEffect(hasAppeared || reduceMotion ? 1 : 0.4)
                .opacity(hasAppeared ? 1 : 0)

                Text("Xfaixa")
                    .font(Typography.display)
                    .foregroundStyle(Color.textPrimary)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared || reduceMotion ? 0 : Spacing.md)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Xfaixa")
        .task {
            withAnimation(reduceMotion ? .easeOut(duration: 0.4) : .spring(duration: 0.7, bounce: 0.45)) {
                hasAppeared = true
            }
            do {
                try await Task.sleep(for: duration)
            } catch {
                // The view went away before the intro finished; the new owner of the screen decides what's next.
                return
            }
            onFinished()
        }
    }

    // MARK: - Private Helpers

    private var sweatDrops: some View {
        ZStack {
            SweatDrop(delay: 0.35)
                .offset(x: -66, y: -4)
            SweatDrop(delay: 0.6, width: 11)
                .offset(x: 68, y: 10)
            SweatDrop(delay: 0.85, width: 12)
                .offset(x: -50, y: 34)
        }
    }
}

#Preview {
    SplashView {}
}
