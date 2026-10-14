import Foundation

/// Sends requests described by an `Endpoint` and decodes their JSON responses.
nonisolated protocol APIClient: Sendable {
    func send<Response>(_ endpoint: Endpoint<Response>) async throws(NetworkError) -> Response
}

/// `APIClient` backed by `URLSession`.
nonisolated final class URLSessionAPIClient: APIClient {

    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Init

    init(baseURL: URL, session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    // MARK: - APIClient

    // @concurrent keeps the request and the JSON decoding off the main actor, even when a @MainActor view model awaits it.
    @concurrent
    func send<Response>(_ endpoint: Endpoint<Response>) async throws(NetworkError) -> Response {
        let url = try endpoint.url(relativeTo: baseURL)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw NetworkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else { throw .invalidResponse }
        guard (200..<300).contains(httpResponse.statusCode) else { throw .httpStatus(httpResponse.statusCode) }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw .decoding
        }
    }
}
