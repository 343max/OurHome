import CoreLocation
import UserNotifications

class LocationChecker: NSObject {
  let locationManager = CLLocationManager()
  let homeRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.53826033352572, longitude: 13.425414271771368),
                                    radius: 50, // m
                                    identifier: "home")
  
  override init() {
    super.init()
    locationManager.delegate = self
    UNUserNotificationCenter.current().delegate = self
    
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.sound, .alert, .badge]) { _, _ in }
  }
  
  func startMonitoring() {
    guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
      return
    }
    
    locationManager.startMonitoring(for: homeRegion)
  }
  
  func stopMonitoring() {
    locationManager.stopMonitoring(for: homeRegion)
  }
}

extension LocationChecker: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    let content = UNMutableNotificationContent()
    content.title = "Haustüröffner drücken"
    content.subtitle = "Tippe diese notification an, um den Haustüröffner zu drücken."
    content.sound = .default
    
    UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString,
                                                                 content: content,
                                                                 trigger: nil))
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .notDetermined:
      locationManager.requestAlwaysAuthorization()
    case .authorizedAlways:
      startMonitoring()
    default:
      break
    }
  }
}

extension LocationChecker: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    try? await sharedHome().pressBuzzer()
  }
}
