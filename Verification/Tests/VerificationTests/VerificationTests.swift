import XCTest
@testable import Verification

final class VerificationTests: XCTestCase {
  func testGenerateSecret() {
    XCTAssertEqual(generateSecret().count, 32)
  }

  func testGenerateToken() {
    let token = generateToken(user: "max", secret: "secret", action: "action", date: 1643212929)
    XCTAssertEqual(token, "bb534a94729ec6ac8b60bb6817d482433ad33f2264646859d0d5be5a9b7d7ecd")

    let otherToken = generateToken(user: "max", secret: "secret1", action: "action2", date: 143212929)
    XCTAssertNotEqual(token, otherToken)
  }

  func testVerifyToken() {
    XCTAssertFalse(verifyToken("invalid", user: "max", secret: "secret", action: "action", date: 1643212929))
    XCTAssertTrue(
      verifyToken(
        "bb534a94729ec6ac8b60bb6817d482433ad33f2264646859d0d5be5a9b7d7ecd",
        user: "max",
        secret: "secret",
        action: "action",
        date: 1643212929
      )
    )
  }

  func testGenerateTokenPayload() {
    let payload = generateTokenPayload(user: "max", secret: "secret", action: "action", date: 15)
    let expected = TokenPayload(
      token: "fdb42b844825c2475e4d9b41aa31c48ce4333ba42c29cdf48aa8c6c60ad8420b",
      date: 15
    )
    XCTAssertEqual(payload, expected)
  }

  func testEncodeTokenPayload() {
    let payload = TokenPayload(token: "aaa", date: 42)
    let json = String(decoding: try! JSONEncoder().encode(payload), as: UTF8.self)
    let expected = """
                   {"token":"aaa","date":42}
                   """
    XCTAssertEqual(json, expected)
  }

  func testDecodeTokenPayload() {
    let json = """
                   {"user":"max","token":"aaa","date":42}
                   """
    let payload = try! JSONDecoder().decode(TokenPayload.self, from: json.data(using: .utf8)!)
    let expected = TokenPayload(token: "aaa", date: 42)
    XCTAssertEqual(payload, expected)
  }
}
