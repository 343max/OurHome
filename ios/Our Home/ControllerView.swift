import SwiftUI

struct ControllerView: View {
  @State private var showDoorOpenerAlert = false
  @State private var state: HomeState? = nil

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
        DoorHeader(locked: .constant(false), batteryState: .constant(BatteryState(level: 95, charging: true, critical: false)))
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
    }.navigationTitle("Our Home")
  }
}

struct ControllerView_Previews: PreviewProvider {
  static var previews: some View {
    ControllerView()
  }
}
