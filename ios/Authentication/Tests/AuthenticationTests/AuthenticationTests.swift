import XCTest
@testable import Authentication

final class AuthenticationTests: XCTestCase {
  func testGetAuthHeader() {
    let authHeader = getAuthHeader(user: "max", secret: "abcdef", action: "knock", timestamp: 4223)
    // make sure it's identical to the one on the server side
    XCTAssertEqual(authHeader, "max/iMai2Pyi17bnMR8yCmzi7Mwf+iHVioMysuBFjr3/QoQ=/4223")
  }
}
