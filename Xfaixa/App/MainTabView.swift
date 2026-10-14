import SwiftUI

/// Main app shell: favorites, profile and the dedicated search tab.
/// Owns the per-user stores and shares them with every tab through the environment.
struct MainTabView: View {

    enum AppTab: Hashable {
        case favorites
        case profile
        case search
    }

    // MARK: - Properties

    let dependencies: AppDependencies
    let user: AppUser

    @State private var selection: AppTab = .search
    @State private var favoritesStore: FavoritesStore

    // MARK: - Init

    init(dependencies: AppDependencies, user: AppUser) {
        self.dependencies = dependencies
        self.user = user
        _favoritesStore = State(initialValue: FavoritesStore(userId: user.id, modelContainer: dependencies.modelContainer))
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selection) {
            Tab("Favoritos", systemImage: "heart.fill", value: .favorites) {
                FavoritesView { selection = .search }
            }
            Tab("Perfil", systemImage: "person.crop.circle", value: .profile) {
                ProfileView(viewModel: ProfileViewModel(
                    user: user,
                    authService: dependencies.authService,
                    avatarStore: dependencies.avatarStore,
                    favoritesStore: favoritesStore
                ))
            }
            Tab("Buscar", systemImage: "magnifyingglass", value: .search, role: .search) {
                SearchView(searchService: dependencies.searchService)
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(.tropicalOrange)
        .environment(favoritesStore)
    }
}

#Preview {
    MainTabView(dependencies: .preview(), user: .preview)
        .environment(RootViewModel.preview())
}
