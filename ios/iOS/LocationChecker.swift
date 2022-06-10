import CoreLocation
import UserNotifications

class LocationChecker: NSObject {
  let locationManager = CLLocationManager()
  let homeRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.53826033352572, longitude: 13.425414271771368),
                                    radius: 50, // m
                                    identifier: "home")
  weak var notificationProvider: NotificationProvider?
  
  init(notificationProvider: NotificationProvider) {
    super.init()
    locationManager.delegate = self
    self.notificationProvider = notificationProvider
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
    notificationProvider?.showBuzzerNotification()
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
