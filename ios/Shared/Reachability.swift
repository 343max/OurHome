import Foundation

enum Distance {
  case Nearby
  case Remote
}

typealias ReachableSetter = (_ reachable: Bool) -> Void

protocol ReachabilityProvider {
  init(distance: Distance)
  var setReachable: ReachableSetter? { get set }
}

class Reachability: ObservableObject {
  @Published private(set) var reachable: Bool = false
  
  private var reachabilityProvider: ReachabilityProvider
  
  init(distance: Distance) {
    #if os(watchOS)
    reachabilityProvider = GeoReachability(distance: distance)
    #else
    reachabilityProvider = NetworkReachability(distance: distance)
    #endif
    reachabilityProvider.setReachable = { [weak self] in self?.reachable = $0 }
  }
}
