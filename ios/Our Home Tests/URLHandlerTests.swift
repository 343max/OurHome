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

    func testLogoutURL() {
        let action = getAction(url: URL(string: "de.343max.ourhome://logout")!)
        XCTAssertEqual(action, .logout)
    }

    func testAssociatedDomain() {
        let action = getAction(url: URL(string: "https://buzzer.343max.com/login?user=max&key=xyz")!)
        XCTAssertEqual(action, .login(username: "max", key: "xyz"))
    }
}
