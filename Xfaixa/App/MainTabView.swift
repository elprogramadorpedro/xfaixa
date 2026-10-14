import SwiftUI

/// Main app shell: favorites, profile and the dedicated search tab.
struct MainTabView: View {

    enum AppTab: Hashable {
        case favorites
        case profile
        case search
    }

    @State private var selection: AppTab = .search

    var body: some View {
        TabView(selection: $selection) {
            Tab("Favoritos", systemImage: "heart.fill", value: .favorites) {
                FavoritesView()
            }
            Tab("Perfil", systemImage: "person.crop.circle", value: .profile) {
                ProfileView()
            }
            Tab("Buscar", systemImage: "magnifyingglass", value: .search, role: .search) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(.tropicalOrange)
    }
}

#Preview {
    MainTabView()
        .environment(RootViewModel(currentUser: .preview))
}
