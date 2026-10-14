import SwiftUI

/// Sheet with a grid of fruit avatars on Liquid Glass circles.
struct FruitPickerView: View {

    // MARK: - Properties

    let selected: Fruit
    let onSelect: (Fruit) -> Void

    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .largeTitle) private var circleSize: CGFloat = 68

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 4)

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.xs) {
                Text("Escolha sua fruta")
                    .font(Typography.title)
                    .foregroundStyle(Color.textPrimary)
                Text("Ela aparece no seu perfil.")
                    .font(Typography.callout)
                    .foregroundStyle(Color.textSecondary)
            }

            GlassEffectContainer(spacing: Spacing.md) {
                LazyVGrid(columns: columns, spacing: Spacing.lg) {
                    ForEach(Fruit.allCases) { fruit in
                        fruitButton(fruit)
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .padding(.top, Spacing.sm)
        .sensoryFeedback(.selection, trigger: selected)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Private Helpers

    private func fruitButton(_ fruit: Fruit) -> some View {
        let isSelected = fruit == selected
        return Button {
            onSelect(fruit)
            Task {
                // Short pause so the selection animation is visible before the sheet slides away.
                try? await Task.sleep(for: .milliseconds(450))
                dismiss()
            }
        } label: {
            VStack(spacing: Spacing.xs) {
                Text(fruit.emoji)
                    .font(.system(size: circleSize * 0.5))
                    .frame(width: circleSize, height: circleSize)
                    .glassEffect(
                        .regular.tint(isSelected ? fruit.tint.opacity(0.45) : nil).interactive(),
                        in: .circle
                    )
                    .scaleEffect(isSelected ? 1.1 : 1)
                    .keyframeAnimator(initialValue: 0.0, trigger: isSelected) { content, angle in
                        // The trigger also fires on the fruit losing selection; only the new pick should wiggle.
                        content.rotationEffect(.degrees(isSelected ? angle : 0))
                    } keyframes: { _ in
                        CubicKeyframe(-12, duration: 0.1)
                        CubicKeyframe(10, duration: 0.12)
                        CubicKeyframe(-6, duration: 0.1)
                        SpringKeyframe(0, duration: 0.25)
                    }

                Text(fruit.name)
                    .font(Typography.caption)
                    .foregroundStyle(isSelected ? Color.deepGreen : Color.textSecondary)
            }
            .animation(.bouncy, value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(fruit.name))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var selected: Fruit = .pineapple

    Color.clear
        .sheet(isPresented: .constant(true)) {
            FruitPickerView(selected: selected) { selected = $0 }
        }
}
