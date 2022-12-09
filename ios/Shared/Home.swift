import Foundation

protocol Home {
  func getState() async throws -> HomeState
  func pressBuzzer() async throws -> HomeResponse
  func unlatchDoor() async throws -> HomeResponse
  func lockDoor() async throws -> HomeResponse
  func unlockDoor() async throws -> HomeResponse
  func armBuzzer() async throws -> HomeResponse
  func armUnlatch() async throws -> HomeResponse
}
