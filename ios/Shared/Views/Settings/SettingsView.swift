import SwiftUI

struct SettingsView: View {
  var body: some View {
    List {
      Section {
        Text("Version \(appVersion())").foregroundColor(.secondary)
      }
    }.navigationTitle("Einstellungen")
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}

