import Foundation

/// Provider-agnostic authentication failures with user-facing messages in Brazilian Portuguese.
nonisolated enum AuthError: Error, Equatable, Sendable {
    case invalidEmail
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case networkUnavailable
    case tooManyRequests
    case unknown

    /// Form field the error belongs to, so it can be shown right under the matching input.
    enum Field: Sendable {
        case email
        case password
    }

    var field: Field? {
        switch self {
        case .invalidEmail, .emailAlreadyInUse: .email
        case .invalidCredentials, .weakPassword: .password
        case .networkUnavailable, .tooManyRequests, .unknown: nil
        }
    }

    var message: String {
        switch self {
        case .invalidEmail: String(localized: "Digite um e-mail válido")
        case .invalidCredentials: String(localized: "E-mail ou senha incorretos")
        case .emailAlreadyInUse: String(localized: "Este e-mail já está cadastrado")
        case .weakPassword: String(localized: "Escolha uma senha mais forte")
        case .networkUnavailable: String(localized: "Sem conexão. Verifique sua internet e tente novamente.")
        case .tooManyRequests: String(localized: "Muitas tentativas. Aguarde um pouco e tente de novo.")
        case .unknown: String(localized: "Algo deu errado. Tente novamente.")
        }
    }
}

extension AuthError: LocalizedError {
    var errorDescription: String? { message }
}
