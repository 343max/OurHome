@testable import Authentication
import XCTest

final class AuthenticationTests: XCTestCase {
    func testGetAuthHeader() {
        let authHeader = getAuthHeader(user: "max", secret: "abcdef", action: "lock", timestamp: 4223)
        // make sure it's identical to the one on the server side
        XCTAssertEqual(authHeader, "max:n4CSFJIbs31PLthxBjdIGJE0pRMI0dAyIFOfhFr4804=:4223")
    }
}
