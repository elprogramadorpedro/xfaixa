import FirebaseAuth
import FirebaseCore
import Foundation

/// `AuthService` backed by Firebase Authentication with email and password.
/// The only type in the app that imports Firebase, so the SDK never leaks into features.
@MainActor
final class FirebaseAuthService: AuthService {

    // MARK: - Properties

    private let auth: Auth

    // MARK: - Init

    init() {
        // Configured here rather than in an app delegate so Firebase stays an implementation detail of this service.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        auth = Auth.auth()
    }

    // MARK: - AuthService

    /// Firebase persists the session in the keychain, so a returning user skips the login screen.
    var currentUser: AppUser? {
        auth.currentUser.flatMap(AppUser.init(firebaseUser:))
    }

    func signIn(email: String, password: String) async throws(AuthError) -> AppUser {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return try appUser(from: result.user)
        } catch {
            throw AuthError(firebaseError: error)
        }
    }

    func signUp(email: String, password: String) async throws(AuthError) -> AppUser {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return try appUser(from: result.user)
        } catch {
            throw AuthError(firebaseError: error)
        }
    }

    func sendPasswordReset(to email: String) async throws(AuthError) {
        do {
            auth.languageCode = "pt-BR"
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw AuthError(firebaseError: error)
        }
    }

    func signOut() throws(AuthError) {
        do {
            try auth.signOut()
        } catch {
            throw AuthError(firebaseError: error)
        }
    }

    // MARK: - Private Helpers

    private func appUser(from user: User) throws(AuthError) -> AppUser {
        guard let appUser = AppUser(firebaseUser: user) else { throw .unknown }
        return appUser
    }
}

// MARK: - Mapping

private extension AppUser {
    init?(firebaseUser: User) {
        guard let email = firebaseUser.email else { return nil }
        self.init(id: firebaseUser.uid, email: email)
    }
}

extension AuthError {
    /// Translates Firebase error codes into the app's own cases, whose messages are already in Portuguese.
    init(firebaseError error: any Error) {
        if let authError = error as? AuthError {
            self = authError
            return
        }
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: nsError.code) else {
            self = .unknown
            return
        }
        switch code {
        case .invalidEmail:
            self = .invalidEmail
        // Email enumeration protection makes Firebase report unknown users and wrong passwords the same way.
        case .wrongPassword, .userNotFound, .invalidCredential:
            self = .invalidCredentials
        case .emailAlreadyInUse:
            self = .emailAlreadyInUse
        case .weakPassword:
            self = .weakPassword
        case .networkError:
            self = .networkUnavailable
        case .tooManyRequests:
            self = .tooManyRequests
        default:
            self = .unknown
        }
    }
}
