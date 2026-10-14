import Foundation

/// Client-side credential rules, checked before any request reaches the auth provider.
nonisolated enum CredentialValidator {
    static let minimumPasswordLength = 6

    static func isValidEmail(_ email: String) -> Bool {
        email.wholeMatch(of: /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/) != nil
    }

    static func isValidPassword(_ password: String) -> Bool {
        password.count >= minimumPasswordLength
    }
}
