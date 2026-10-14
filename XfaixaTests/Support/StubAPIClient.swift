import Foundation
@testable import Xfaixa

/// Decodes a canned payload, or fails with a canned error, for any endpoint it receives.
struct StubAPIClient: APIClient {
    let result: Result<Data, NetworkError>

    func send<Response>(_ endpoint: Endpoint<Response>) async throws(NetworkError) -> Response {
        let data = try result.get()
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw .decoding
        }
    }
}
