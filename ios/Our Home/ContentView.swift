import SwiftUI

struct ContentView: View {
  @State private var showDoorOpenerAlert = false

  var body: some View {
    List() {
      Section("Haustür") {
        SpinningButton(spinning: .constant(false)) {
          print("was tapped")
        } label: {
          Label("Haustür öffnen", systemImage: "figure.walk")
        }.disabled(true)
      }
      Section() {
        SpinningButton(spinning: .constant(true)) {
          showDoorOpenerAlert = true
        } label: {
          Label("Wohnungstür öffnen", systemImage: "lock").foregroundColor(.red)
        }.alert(isPresented: $showDoorOpenerAlert) {
          Alert(
            title: Text("Wohnungstür öffnen?"),
            message: Text("Wenn die Wohnungstür geöffnet wurde, kann sie nicht automatisch wieder geschlossen werden."),
            primaryButton: .default(Text("Abbrechen")) { showDoorOpenerAlert = false },
            secondaryButton: .destructive(Text("Wohnungstür öffnen")) { showDoorOpenerAlert = false })
        }
      } header: {
        DoorHeader(locked: .constant(false), batteryLevel: .constant(95), batteryCharging: .constant(true), batteryCritical: .constant(false))
      }
      Section() {
        SpinningButton(spinning: .constant(false)) {
          print("was tapped")
        } label: {
          Label("Wohnungstür aufschließen", systemImage: "lock.open")
        }
        SpinningButton(spinning: .constant(false)) {
          print("was tapped")
        } label: {
          Label("Wohnungstür abschließen", systemImage: "lock")
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
