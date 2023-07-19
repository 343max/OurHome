import SwiftUI

struct SettingsButtonLabel: View {
  @State var userState: UserState
  
  var body: some View {
    switch userState {
    case .loggedOut:
      Label("Einstellungen", systemImage: "teddybear").foregroundColor(.orange)
    case .loginFailed:
      Label("Einstellungen", systemImage: "person.crop.circle.badge.exclamationmark.fill").foregroundColor(.red)
    case .loginExpired:
      Label("Einstellungen", systemImage: "calendar.badge.exclamationmark").foregroundColor(.red)
    case .loggedIn, .verifying:
      Label("Einstellungen", systemImage: "slider.horizontal.3")
    }
  }
}

#Preview {
  SettingsButtonLabel(userState: .loggedOut)
}
