import XCTest
@testable import Authentication

final class AuthenticationTests: XCTestCase {
  func testGetAuthHeader() {
    let authHeader = getAuthHeader(user: "max", secret: "abcdef", action: "knock", timestamp: 4223)
    XCTAssertEqual(authHeader, "max/W+NY2oWK9s6GACoWmvuj8D2yQ4lIF5BRGblvWGYWpvc=/4223")
  }
}
