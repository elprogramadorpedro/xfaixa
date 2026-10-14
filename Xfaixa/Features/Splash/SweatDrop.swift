import SwiftUI

/// Liquid Glass droplet that pops in after a delay, slides down and fades out.
struct SweatDrop: View {

    // MARK: - Properties

    let delay: Double
    var width: CGFloat = 14

    private struct DropState {
        var scale: CGFloat = 0
        var offsetY: CGFloat = 0
        var opacity: Double = 0
    }

    // MARK: - Body

    var body: some View {
        Color.clear
            .frame(width: width, height: width * 1.4)
            .glassEffect(.regular.tint(.white.opacity(0.25)), in: DropShape())
            .overlay(alignment: .bottomLeading) {
                Circle()
                    .fill(.white.opacity(0.85))
                    .frame(width: width * 0.28)
                    .offset(x: width * 0.24, y: -width * 0.32)
            }
            .keyframeAnimator(initialValue: DropState(), repeating: true) { content, state in
                content
                    .scaleEffect(state.scale, anchor: .top)
                    .offset(y: state.offsetY)
                    .opacity(state.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(0, duration: delay)
                    SpringKeyframe(1, duration: 0.3, spring: .bouncy)
                    LinearKeyframe(1, duration: 1)
                }
                KeyframeTrack(\.offsetY) {
                    LinearKeyframe(0, duration: delay + 0.3)
                    CubicKeyframe(width * 2, duration: 1)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0, duration: delay)
                    LinearKeyframe(1, duration: 0.15)
                    LinearKeyframe(1, duration: 0.75)
                    LinearKeyframe(0, duration: 0.4)
                }
            }
            .accessibilityHidden(true)
    }
}

/// Teardrop with a pointed top and a round bottom.
private struct DropShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX + rect.width * 0.1, y: rect.midY),
            control2: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.maxY),
            control2: CGPoint(x: rect.minX - rect.width * 0.1, y: rect.midY)
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.tropicalOrange.ignoresSafeArea()
        HStack(spacing: Spacing.lg) {
            SweatDrop(delay: 0, width: 40)
            SweatDrop(delay: 0.4, width: 40)
        }
    }
}
