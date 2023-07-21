import SwiftUI

struct ActionLabel: View {
  let action: HomeAction
  
  var body: some View {
    switch action {
    case .unlockDoor:
      Label("Wohnungstür aufschließen", systemImage: "lock.open")
    }
  }
}
