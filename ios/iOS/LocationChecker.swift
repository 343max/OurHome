import CoreLocation
import UserNotifications

class LocationChecker: NSObject {
    var home: Home

    let locationManager = CLLocationManager()
    let homeRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 52.53826033352572, longitude: 13.425414271771368),
                                      radius: 50, // m
                                      identifier: "home")

    var setNearby: ((_ nearby: Bool) -> Void)?
    var nearby = false

    weak var notificationProvider: NotificationProvider?

    init(home: Home, notificationProvider: NotificationProvider) {
        self.home = home
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true

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
    func locationManager(_: CLLocationManager, didEnterRegion _: CLRegion) {
        notificationProvider?.showBuzzerNotification()

        setNearby?(true)
        nearby = true

        Task {
            let _ = try? await home.action(.arrived)
        }
    }

    func locationManager(_: CLLocationManager, didExitRegion _: CLRegion) {
        setNearby?(false)
        nearby = false
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
