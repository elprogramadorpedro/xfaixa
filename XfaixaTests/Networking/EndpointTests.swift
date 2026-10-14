import Foundation
import Testing
@testable import Xfaixa

struct EndpointTests {

    @Test func songSearchBuildsTheExpectedURL() throws {
        let url = try Endpoint.songSearch(term: "bossa nova", limit: 25).url(relativeTo: .iTunesAPI)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })

        #expect(components.host == "itunes.apple.com")
        #expect(components.path == "/search")
        #expect(query["term"] == "bossa nova")
        #expect(query["entity"] == "song")
        #expect(query["country"] == "BR")
        #expect(query["limit"] == "25")
    }

    @Test func termIsPercentEncoded() throws {
        let url = try Endpoint.songSearch(term: "são joão").url(relativeTo: .iTunesAPI)

        #expect(url.absoluteString.contains("term=s%C3%A3o%20jo%C3%A3o"))
    }
}
