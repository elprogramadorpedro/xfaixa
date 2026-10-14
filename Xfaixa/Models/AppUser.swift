import Foundation

/// Authenticated user as the app sees it, decoupled from any auth provider SDK type.
nonisolated struct AppUser: Identifiable, Hashable, Sendable {
    let id: String
    let email: String
}

extension AppUser {
    static let preview = AppUser(id: "preview-user", email: "ana@xfaixa.app")
}
