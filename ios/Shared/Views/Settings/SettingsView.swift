import SwiftUI

struct SettingsView: View {
  var body: some View {
    List {
      Text("Version \(appVersion())")
    }.navigationTitle("Einstellungen")
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
