import Foundation

/// Transport and decoding failures surfaced by `APIClient`, with user-facing messages in Brazilian Portuguese.
nonisolated enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case offline
    case timedOut
    case cancelled
    case invalidResponse
    case httpStatus(Int)
    case decoding
    case unknown

    init(_ error: any Error) {
        switch error {
        case let networkError as NetworkError:
            self = networkError
        case is CancellationError:
            self = .cancelled
        case let urlError as URLError:
            self = Self(urlErrorCode: urlError.code)
        case is DecodingError:
            self = .decoding
        default:
            self = .unknown
        }
    }

    private init(urlErrorCode code: URLError.Code) {
        switch code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .internationalRoamingOff:
            self = .offline
        case .timedOut:
            self = .timedOut
        case .cancelled:
            self = .cancelled
        case .badURL, .unsupportedURL:
            self = .invalidURL
        case .badServerResponse, .cannotParseResponse:
            self = .invalidResponse
        default:
            self = .unknown
        }
    }

    var message: String {
        switch self {
        case .offline: String(localized: "Você está sem conexão. Verifique sua internet.")
        case .timedOut: String(localized: "O servidor demorou para responder. Tente novamente.")
        case .httpStatus, .invalidResponse, .decoding: String(localized: "Recebemos uma resposta inesperada do servidor.")
        case .invalidURL, .cancelled, .unknown: String(localized: "Algo deu errado. Tente novamente.")
        }
    }
}

extension NetworkError: LocalizedError {
    var errorDescription: String? { message }
}
