import Foundation

/// `AuthService` backed by an in-memory account list. Simulates network latency and the same
/// failure cases as a real provider, so the whole auth flow can run without a backend.
@MainActor
final class InMemoryAuthService: AuthService {

    private struct Account {
        let user: AppUser
        let password: String
    }

    // MARK: - Properties

    private(set) var currentUser: AppUser?
    private var accounts: [String: Account]
    private let latency: Duration

    // MARK: - Init

    init(latency: Duration = .milliseconds(800), currentUser: AppUser? = nil) {
        self.latency = latency
        self.currentUser = currentUser
        let demo = AppUser(id: "demo-user", email: "demo@xfaixa.app")
        accounts = [demo.email: Account(user: demo, password: "123456")]
    }

    // MARK: - AuthService

    func signIn(email: String, password: String) async throws(AuthError) -> AppUser {
        await simulateLatency()
        guard let account = accounts[normalized(email)], account.password == password else {
            throw .invalidCredentials
        }
        currentUser = account.user
        return account.user
    }

    func signUp(email: String, password: String) async throws(AuthError) -> AppUser {
        await simulateLatency()
        let key = normalized(email)
        guard accounts[key] == nil else { throw .emailAlreadyInUse }
        guard CredentialValidator.isValidPassword(password) else { throw .weakPassword }

        let user = AppUser(id: UUID().uuidString, email: key)
        accounts[key] = Account(user: user, password: password)
        currentUser = user
        return user
    }

    func sendPasswordReset(to email: String) async throws(AuthError) {
        // Succeeds for unknown emails too, mirroring providers that avoid revealing which accounts exist.
        await simulateLatency()
    }

    func signOut() throws(AuthError) {
        currentUser = nil
    }

    // MARK: - Private Helpers

    private func normalized(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func simulateLatency() async {
        try? await Task.sleep(for: latency)
    }
}
