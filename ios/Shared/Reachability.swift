import Foundation

enum Distance {
  case Nearby
  case Remote
}

typealias ReachableSetter = (_ reachable: Bool) -> Void

protocol ReachabilityProvider {
  var setReachable: ReachableSetter? { get set }
}

class Reachability: ObservableObject {
  @Published private(set) var reachable: Bool = false
  
  private var reachabilityProvider: ReachabilityProvider
  
  init(distance: Distance, home: Home) {
    #if os(watchOS)
    reachabilityProvider = GeoReachability(distance: distance)
    #else
    reachabilityProvider = NetworkReachability(distance: distance, home: home)
    #endif
    reachabilityProvider.setReachable = { [weak self] in self?.reachable = $0 }
  }
}
