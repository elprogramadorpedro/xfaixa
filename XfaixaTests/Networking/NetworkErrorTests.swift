import Foundation
import Testing
@testable import Xfaixa

struct NetworkErrorTests {

    @Test(arguments: [
        (URLError.Code.notConnectedToInternet, NetworkError.offline),
        (.networkConnectionLost, .offline),
        (.timedOut, .timedOut),
        (.cancelled, .cancelled),
        (.badServerResponse, .invalidResponse),
        (.cannotFindHost, .unknown)
    ])
    func mapsURLErrors(code: URLError.Code, expected: NetworkError) {
        #expect(NetworkError(URLError(code)) == expected)
    }

    @Test func mapsTaskCancellation() {
        #expect(NetworkError(CancellationError()) == .cancelled)
    }

    @Test func keepsNetworkErrorsUntouched() {
        #expect(NetworkError(NetworkError.httpStatus(503)) == .httpStatus(503))
    }
}
