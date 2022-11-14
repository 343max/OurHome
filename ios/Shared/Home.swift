import Foundation

protocol Home {
  func getState() async throws -> HomeState
  func pressBuzzer() async throws -> HomeResponse
  func unlatchDoor() async throws -> HomeResponse
  func lockDoor() async throws -> HomeResponse
  func unlockDoor() async throws -> HomeResponse
  func arrived() async throws -> HomeResponse 
}
