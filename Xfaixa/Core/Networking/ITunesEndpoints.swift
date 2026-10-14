import Foundation

nonisolated extension URL {
    static let iTunesAPI = URL(string: "https://itunes.apple.com")!
}

nonisolated extension Endpoint where Response == ITunesSearchResponse {
    /// Song search in the Brazilian storefront, so local artists rank the way users expect.
    static func songSearch(term: String, limit: Int = 50) -> Endpoint {
        Endpoint(
            path: "search",
            queryItems: [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "country", value: "BR"),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        )
    }
}
