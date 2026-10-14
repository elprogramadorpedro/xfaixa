import Foundation

/// Email and password authentication. Implementations translate provider failures into `AuthError`
/// so the UI never depends on a specific SDK.
@MainActor
protocol AuthService: AnyObject {
    /// The signed-in user restored from the provider's session, if any.
    var currentUser: AppUser? { get }

    func signIn(email: String, password: String) async throws(AuthError) -> AppUser
    func signUp(email: String, password: String) async throws(AuthError) -> AppUser
    func sendPasswordReset(to email: String) async throws(AuthError)
    func signOut() throws(AuthError)
}
