import Foundation

enum HomeAction {
  case lockDoor
  case unlockDoor
  case unlatchDoor
  case pressBuzzer
  case armBuzzer
  case armUnlatch
  case arrived
}

protocol Home {
  var localNetworkHost: URL { get }
  var externalHost: URL { get }
  
  func getState() async throws -> HomeState
  
  func action(_ action: HomeAction) async throws -> HomeResponse
}
