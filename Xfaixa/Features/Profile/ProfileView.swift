import SwiftUI

/// Profile tab: fruit avatar, account email, favorites count and sign out.
struct ProfileView: View {

    // MARK: - Properties

    @State private var viewModel: ProfileViewModel
    @Environment(RootViewModel.self) private var rootViewModel

    @ScaledMetric(relativeTo: .largeTitle) private var avatarSize = Size.avatar

    // MARK: - Init

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    VStack(spacing: Spacing.md) {
                        avatar
                        Text(verbatim: viewModel.user.email)
                            .font(Typography.headline)
                            .foregroundStyle(Color.textPrimary)
                    }

                    stats

                    VStack(spacing: Spacing.sm) {
                        Button(role: .destructive) {
                            viewModel.isConfirmingSignOut = true
                        } label: {
                            Label("Sair da conta", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(Typography.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glass)
                        .controlSize(.large)
                        .tint(.errorRed)
                        // Attached to the button so the iOS 26 popover-style dialog points at it.
                        .confirmationDialog("Sair da conta?", isPresented: $viewModel.isConfirmingSignOut, titleVisibility: .visible) {
                            Button("Sair", role: .destructive) {
                                if viewModel.signOut() {
                                    rootViewModel.didSignOut()
                                }
                            }
                            Button("Cancelar", role: .cancel) {}
                        } message: {
                            Text("Seus favoritos continuam salvos neste aparelho.")
                        }

                        if let signOutError = viewModel.signOutError {
                            Text(signOutError)
                                .font(Typography.footnote)
                                .foregroundStyle(Color.errorRed)
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { TropicalBackground() }
            .navigationTitle("Perfil")
            .sheet(isPresented: $viewModel.isPickingFruit) {
                FruitPickerView(selected: viewModel.fruit, onSelect: viewModel.selectFruit)
            }
        }
    }

    // MARK: - Private Helpers

    private var avatar: some View {
        Button {
            viewModel.isPickingFruit = true
        } label: {
            Text(viewModel.fruit.emoji)
                .font(.system(size: avatarSize * 0.5))
                .contentTransition(.numericText())
                .accessibilityHidden(true)
                .frame(width: avatarSize, height: avatarSize)
                .glassEffect(.regular.tint(viewModel.fruit.tint.opacity(0.35)).interactive(), in: .circle)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "pencil")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.deepGreen)
                        .padding(Spacing.xs)
                        .glassEffect(.regular, in: .circle)
                }
                .animation(.bouncy, value: viewModel.fruit)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Avatar: \(Text(viewModel.fruit.name))"))
        .accessibilityHint("Toque para escolher outra fruta")
    }

    private var stats: some View {
        HStack(spacing: Spacing.md) {
            statCard(
                value: Text(viewModel.favoritesCount, format: .number),
                label: Text("Músicas favoritas"),
                systemImage: "heart.fill",
                tint: .tropicalOrange
            )
            statCard(
                // The emoji is decorative here; VoiceOver reads the fruit name below it.
                value: Text(viewModel.fruit.emoji).accessibilityHidden(true),
                label: Text(viewModel.fruit.name),
                systemImage: "leaf.fill",
                tint: .leafGreen
            )
        }
    }

    private func statCard(value: some View, label: Text, systemImage: String, tint: Color) -> some View {
        GlassCard(tint: tint.opacity(0.18)) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
                value
                    .font(Typography.display)
                    .foregroundStyle(Color.textPrimary)
                    .contentTransition(.numericText())
                label
                    .font(Typography.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    ProfileView(viewModel: ProfileViewModel(
        user: .preview,
        authService: dependencies.authService,
        avatarStore: dependencies.avatarStore,
        favoritesStore: .preview()
    ))
    .environment(RootViewModel.preview())
}
