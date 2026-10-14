import Foundation
import Testing
@testable import Xfaixa

/// Uses Firebase's documented domain and raw codes, so the mapping is verified without talking to Firebase.
struct FirebaseAuthErrorMappingTests {

    private static let domain = "FIRAuthErrorDomain"

    @Test(arguments: [
        (17008, AuthError.invalidEmail),
        (17009, .invalidCredentials),
        (17011, .invalidCredentials),
        (17004, .invalidCredentials),
        (17007, .emailAlreadyInUse),
        (17026, .weakPassword),
        (17020, .networkUnavailable),
        (17010, .tooManyRequests),
        (17005, .unknown)
    ])
    func mapsFirebaseCodes(code: Int, expected: AuthError) {
        let error = NSError(domain: Self.domain, code: code)

        #expect(AuthError(firebaseError: error) == expected)
    }

    @Test func errorsFromOtherDomainsAreUnknown() {
        #expect(AuthError(firebaseError: URLError(.notConnectedToInternet)) == .unknown)
    }

    @Test func authErrorsPassThrough() {
        #expect(AuthError(firebaseError: AuthError.weakPassword) == .weakPassword)
    }
}
