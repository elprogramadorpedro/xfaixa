import Foundation
import Observation

/// State and validation for the sign in, sign up and password reset screens.
/// Shared across the auth flow so the email typed on one screen carries over to the next.
@MainActor
@Observable
final class AuthViewModel {

    enum Mode {
        case signIn
        case signUp
    }

    enum ResetState: Equatable {
        case idle
        case sending
        case sent
    }

    // MARK: - Properties

    var email = "" {
        didSet { if email != oldValue { serverError = nil } }
    }
    var password = "" {
        didSet { if password != oldValue { serverError = nil } }
    }
    var confirmPassword = ""
    var resetEmail = "" {
        didSet { if resetEmail != oldValue { resetError = nil } }
    }

    private(set) var mode: Mode = .signIn
    private(set) var isLoading = false
    private(set) var serverError: AuthError?
    private(set) var resetState: ResetState = .idle
    private(set) var resetError: String?
    private var hasSubmitted = false

    private let authService: any AuthService

    // MARK: - Init

    init(authService: any AuthService) {
        self.authService = authService
    }

    // MARK: - Validation

    var emailError: String? {
        if let serverError, serverError.field == .email { return serverError.message }
        guard shouldValidate(email) else { return nil }
        if trimmedEmail.isEmpty { return String(localized: "Informe seu e-mail") }
        if !CredentialValidator.isValidEmail(trimmedEmail) { return AuthError.invalidEmail.message }
        return nil
    }

    var passwordError: String? {
        if let serverError, serverError.field == .password { return serverError.message }
        guard shouldValidate(password) else { return nil }
        if password.isEmpty { return String(localized: "Informe sua senha") }
        if mode == .signUp, !CredentialValidator.isValidPassword(password) {
            return String(localized: "A senha precisa ter pelo menos \(CredentialValidator.minimumPasswordLength) caracteres")
        }
        return nil
    }

    var confirmPasswordError: String? {
        guard mode == .signUp, shouldValidate(confirmPassword) else { return nil }
        return confirmPassword == password ? nil : String(localized: "As senhas não coincidem")
    }

    /// Failures that don't belong to a specific field, such as connectivity problems.
    var generalError: String? {
        guard let serverError, serverError.field == nil else { return nil }
        return serverError.message
    }

    var canSubmitSignUp: Bool {
        CredentialValidator.isValidEmail(trimmedEmail)
            && CredentialValidator.isValidPassword(password)
            && confirmPassword == password
    }

    // MARK: - Public API

    func switchMode(to newMode: Mode) {
        mode = newMode
        hasSubmitted = false
        serverError = nil
        password = ""
        confirmPassword = ""
    }

    func signIn() async -> AppUser? {
        await submit { [authService, trimmedEmail, password] () async throws(AuthError) -> AppUser in
            try await authService.signIn(email: trimmedEmail, password: password)
        }
    }

    func signUp() async -> AppUser? {
        await submit { [authService, trimmedEmail, password] () async throws(AuthError) -> AppUser in
            try await authService.signUp(email: trimmedEmail, password: password)
        }
    }

    func prepareReset() {
        resetEmail = trimmedEmail
        resetState = .idle
        resetError = nil
    }

    func sendPasswordReset() async {
        let email = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard CredentialValidator.isValidEmail(email) else {
            resetError = AuthError.invalidEmail.message
            return
        }

        resetState = .sending
        do {
            try await authService.sendPasswordReset(to: email)
            resetState = .sent
        } catch {
            resetState = .idle
            resetError = error.message
        }
    }

    // MARK: - Private Helpers

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isFormValid: Bool {
        switch mode {
        case .signIn: CredentialValidator.isValidEmail(trimmedEmail) && !password.isEmpty
        case .signUp: canSubmitSignUp
        }
    }

    /// Sign up validates while the user types; sign in waits for the first submit so returning users aren't nagged.
    private func shouldValidate(_ value: String) -> Bool {
        hasSubmitted || (mode == .signUp && !value.isEmpty)
    }

    private func submit(_ request: () async throws(AuthError) -> AppUser) async -> AppUser? {
        hasSubmitted = true
        guard isFormValid, !isLoading else { return nil }

        isLoading = true
        defer { isLoading = false }

        do {
            return try await request()
        } catch {
            serverError = error
            return nil
        }
    }
}
