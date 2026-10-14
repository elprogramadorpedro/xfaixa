import SwiftUI

/// Friendly pineapple mascot drawn entirely with SwiftUI shapes, so it stays crisp at any size.
struct PineappleView: View {

    // MARK: - Properties

    var size: CGFloat = 160
    var isSwaying = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var crownHeight: CGFloat { size * 0.62 }
    private var fruitWidth: CGFloat { size * 0.84 }
    private var fruitHeight: CGFloat { size * 0.96 }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            crown
                .frame(maxHeight: .infinity, alignment: .top)
            fruit
        }
        .frame(width: size, height: size * 1.5)
        .accessibilityElement()
        .accessibilityLabel("Abacaxi")
    }

    // MARK: - Crown

    @ViewBuilder
    private var crown: some View {
        if isSwaying && !reduceMotion {
            PhaseAnimator([-1.0, 1.0]) { phase in
                leaves(sway: phase)
            } animation: { _ in
                .easeInOut(duration: 1.1)
            }
        } else {
            leaves(sway: 0)
        }
    }

    private func leaves(sway: Double) -> some View {
        ZStack(alignment: .bottom) {
            ForEach(Self.leafSpecs.indices, id: \.self) { index in
                let spec = Self.leafSpecs[index]
                Leaf()
                    .fill(LinearGradient(colors: [spec.tip, spec.base], startPoint: .top, endPoint: .bottom))
                    .frame(width: size * 0.26, height: crownHeight * spec.length)
                    .rotationEffect(.degrees(spec.angle + sway * spec.swayAmplitude), anchor: .bottom)
            }
        }
        .frame(width: size, height: crownHeight, alignment: .bottom)
    }

    // MARK: - Fruit

    private var fruit: some View {
        ZStack {
            Ellipse()
                .fill(LinearGradient(colors: [Mascot.rindTop, Mascot.rindBottom], startPoint: .top, endPoint: .bottom))
            DiamondPattern(style: .tiles)
                .fill(LinearGradient(colors: [Mascot.tileTop, Mascot.tileBottom], startPoint: .top, endPoint: .bottom))
            DiamondPattern(style: .seeds)
                .fill(Mascot.seed)
            face
        }
        .clipShape(Ellipse())
        .frame(width: fruitWidth, height: fruitHeight)
    }

    private var face: some View {
        let eyeSize = CGSize(width: size * 0.075, height: size * 0.1)
        return ZStack {
            HStack(spacing: fruitWidth * 0.3) {
                eye(size: eyeSize)
                eye(size: eyeSize)
            }
            .offset(y: -fruitHeight * 0.08)

            HStack(spacing: fruitWidth * 0.46) {
                Ellipse().fill(Mascot.blush)
                Ellipse().fill(Mascot.blush)
            }
            .frame(width: fruitWidth * 0.72, height: size * 0.07)
            .offset(y: fruitHeight * 0.04)

            Smile()
                .stroke(Mascot.face, style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
                .frame(width: size * 0.16, height: size * 0.07)
                .offset(y: fruitHeight * 0.06)
        }
    }

    private func eye(size eyeSize: CGSize) -> some View {
        Capsule()
            .fill(Mascot.face)
            .frame(width: eyeSize.width, height: eyeSize.height)
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(.white)
                    .frame(width: eyeSize.width * 0.4)
                    .offset(x: -eyeSize.width * 0.12, y: eyeSize.height * 0.15)
            }
    }
}

// MARK: - Mascot Palette

/// Fixed colors so the mascot looks the same in light and dark mode, like any illustration would.
private enum Mascot {
    static let rindTop = Color(hex: 0xF59A00)
    static let rindBottom = Color(hex: 0xE57A00)
    static let tileTop = Color(hex: 0xFFD43B)
    static let tileBottom = Color(hex: 0xFFAA1F)
    static let seed = Color(hex: 0xE07B00).opacity(0.7)
    static let face = Color(hex: 0x3B2510)
    static let blush = Color(hex: 0xFF6F61).opacity(0.45)
    static let leafLight = Color(hex: 0x5BD97A)
    static let leafMid = Color(hex: 0x34C759)
    static let leafDark = Color(hex: 0x1E8E4E)
}

private struct LeafSpec {
    let angle: Double
    let length: CGFloat
    let swayAmplitude: Double
    let tip: Color
    let base: Color
}

private extension PineappleView {
    /// Back leaves are listed first so the front ones are drawn on top.
    static let leafSpecs: [LeafSpec] = [
        LeafSpec(angle: -50, length: 0.74, swayAmplitude: 3, tip: Mascot.leafMid, base: Mascot.leafDark),
        LeafSpec(angle: 50, length: 0.74, swayAmplitude: -3, tip: Mascot.leafMid, base: Mascot.leafDark),
        LeafSpec(angle: -30, length: 0.86, swayAmplitude: -4, tip: Mascot.leafLight, base: Mascot.leafDark),
        LeafSpec(angle: 30, length: 0.86, swayAmplitude: 4, tip: Mascot.leafLight, base: Mascot.leafDark),
        LeafSpec(angle: 0, length: 1, swayAmplitude: 2.5, tip: Mascot.leafLight, base: Mascot.leafMid)
    ]
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// MARK: - Shapes

/// Pointed leaf with a rounded tip, anchored at the bottom center.
private struct Leaf: Shape {
    func path(in rect: CGRect) -> Path {
        let tipRadius = rect.width * 0.14
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX - tipRadius, y: rect.minY + tipRadius),
            control: CGPoint(x: rect.minX - rect.width * 0.1, y: rect.midY + rect.height * 0.1)
        )
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.minY + tipRadius),
            radius: tipRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX + rect.width * 0.1, y: rect.midY + rect.height * 0.1)
        )
        path.closeSubpath()
        return path
    }
}

/// Grid of rounded rhombi that recreates the pineapple rind, or the small seed in the middle of each one.
private struct DiamondPattern: Shape {
    enum Style { case tiles, seeds }

    let style: Style
    var columns = 4

    func path(in rect: CGRect) -> Path {
        let tileWidth = rect.width / CGFloat(columns)
        let tileHeight = tileWidth * 1.15
        let rows = Int((rect.height / (tileHeight / 2)).rounded(.up)) + 1
        var path = Path()

        for row in 0...rows {
            let y = rect.minY + CGFloat(row) * tileHeight / 2
            // Odd rows shift half a tile so the rhombi interlock like a real rind.
            let shift = row.isMultiple(of: 2) ? 0 : tileWidth / 2
            for column in -1...columns {
                let center = CGPoint(x: rect.minX + shift + CGFloat(column) * tileWidth, y: y)
                switch style {
                case .tiles:
                    path.addPath(rhombus(center: center, halfWidth: tileWidth * 0.43, halfHeight: tileHeight * 0.43))
                case .seeds:
                    let seed = CGSize(width: tileWidth * 0.12, height: tileHeight * 0.14)
                    path.addEllipse(in: CGRect(
                        x: center.x - seed.width / 2,
                        y: center.y - seed.height / 2 + tileHeight * 0.06,
                        width: seed.width,
                        height: seed.height
                    ))
                }
            }
        }
        return path
    }

    private func rhombus(center: CGPoint, halfWidth: CGFloat, halfHeight: CGFloat) -> Path {
        let top = CGPoint(x: center.x, y: center.y - halfHeight)
        let right = CGPoint(x: center.x + halfWidth, y: center.y)
        let bottom = CGPoint(x: center.x, y: center.y + halfHeight)
        let left = CGPoint(x: center.x - halfWidth, y: center.y)
        let radius = halfWidth * 0.35

        var path = Path()
        path.move(to: CGPoint(x: (left.x + top.x) / 2, y: (left.y + top.y) / 2))
        path.addArc(tangent1End: top, tangent2End: right, radius: radius)
        path.addArc(tangent1End: right, tangent2End: bottom, radius: radius)
        path.addArc(tangent1End: bottom, tangent2End: left, radius: radius)
        path.addArc(tangent1End: left, tangent2End: top, radius: radius)
        path.closeSubpath()
        return path
    }
}

private struct Smile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY * 1.6)
        )
        return path
    }
}

#Preview {
    ZStack {
        TropicalBackground()
        HStack(alignment: .bottom, spacing: Spacing.lg) {
            PineappleView(size: 64)
            PineappleView(size: 180, isSwaying: true)
        }
    }
}
