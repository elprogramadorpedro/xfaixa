import Foundation

/// Describes a GET request and the type its JSON response decodes into.
nonisolated struct Endpoint<Response: Decodable & Sendable>: Sendable {
    let path: String
    var queryItems: [URLQueryItem] = []

    func url(relativeTo baseURL: URL) throws(NetworkError) -> URL {
        guard var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false) else {
            throw .invalidURL
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else { throw .invalidURL }
        return url
    }
}
