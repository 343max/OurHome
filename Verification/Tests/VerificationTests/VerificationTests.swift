import XCTest
@testable import Verification

final class VerificationTests: XCTestCase {
  func testGenerateSecret() {
    XCTAssertEqual(generateSecret().count, 32)
  }

  func testGenerateToken() {
    let token = generateToken(secret: "secret", action: "action", date: 1643212929)
    XCTAssertEqual(token, "3d743f8857834b37e290e43992cb99411e005a90597632cb620211143a3a0d4d")

    let otherToken = generateToken(secret: "secret1", action: "action2", date: 143212929)
    XCTAssertNotEqual(token, otherToken)
  }

  func testVerifyToken() {
    XCTAssertFalse(verifyToken("invalid", secret: "secret", action: "action", date: 1643212929))
    XCTAssertTrue(
      verifyToken(
        "3d743f8857834b37e290e43992cb99411e005a90597632cb620211143a3a0d4d",
        secret: "secret",
        action: "action",
        date: 1643212929
      )
    )
  }
  
  func testGenerateTokenPayload() {
    let payload = generateTokenPayload(secret: "secret", action: "action", date: 15)
    let expected = TokenPayload(
      token: "8b3329f16bcc4a45a44d244359e80468722230c71f96395b1f40d0eafe47e7dd",
      action: "action",
      date: "15"
    )
    XCTAssertEqual(payload, expected)
  }
}
