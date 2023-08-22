import XCTest

@testable import Our_Home

final class HomeStateTests: XCTestCase {
  func testParseHomeState() throws {
    let data = "{\"success\":true,\"doorlock\":{\"state\":3,\"batteryCritical\":false,\"batteryCharging\":false,\"batteryChargeState\":68,\"success\":true},\"doorbellAction\":null}".data(using: .utf8)!
    
    let state = try JSONDecoder().decode(HomeState.self, from: data)
    XCTAssertEqual(state.doorlock?.batteryChargeState, 68)
  }
}
