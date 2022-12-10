import XCTest

@testable import Our_Home

final class URLHandlerTests: XCTestCase {
  func testUknownURL() {
    let action = getAction(url: URL(string: "de.343max.ourhome://unknownAction")!)
    XCTAssertNil(action)
  }
  
  func testLoginURL() {
    let action = getAction(url: URL(string: "de.343max.ourhome://login?user=max&key=xyz")!)
    XCTAssertEqual(action, .login(username: "max", key: "xyz"))
  }
}
