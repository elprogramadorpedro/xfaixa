import SwiftUI

/// Profile tab: account details, avatar and sign out.
struct ProfileView: View {
    @Environment(RootViewModel.self) private var rootViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.md) {
                SymbolIllustration(systemImage: "person.crop.circle")
                if let email = rootViewModel.currentUser?.email {
                    Text(verbatim: email)
                        .font(Typography.headline)
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { TropicalBackground() }
            .navigationTitle("Perfil")
        }
    }
}

#Preview {
    ProfileView()
        .environment(RootViewModel(currentUser: .preview))
}
