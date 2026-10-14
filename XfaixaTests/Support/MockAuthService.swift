import Foundation
@testable import Xfaixa

/// `AuthService` with canned outcomes per operation and a log of the calls it received.
@MainActor
final class MockAuthService: AuthService {
    var currentUser: AppUser?

    var signInResult: Result<AppUser, AuthError> = .success(.fixture)
    var signUpResult: Result<AppUser, AuthError> = .success(.fixture)
    var resetResult: Result<Void, AuthError> = .success(())
    var signOutError: AuthError?

    private(set) var signInCalls: [(email: String, password: String)] = []
    private(set) var signUpCalls: [(email: String, password: String)] = []
    private(set) var resetEmails: [String] = []
    private(set) var signOutCount = 0

    func signIn(email: String, password: String) async throws(AuthError) -> AppUser {
        signInCalls.append((email, password))
        return try signInResult.get()
    }

    func signUp(email: String, password: String) async throws(AuthError) -> AppUser {
        signUpCalls.append((email, password))
        return try signUpResult.get()
    }

    func sendPasswordReset(to email: String) async throws(AuthError) {
        resetEmails.append(email)
        try resetResult.get()
    }

    func signOut() throws(AuthError) {
        signOutCount += 1
        if let signOutError { throw signOutError }
        currentUser = nil
    }
}
