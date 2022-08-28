import Foundation

class GeoReachability: ReachabilityProvider {
  private let reachable: Bool
  
  required init(distance: Distance) {
    // dummy
    reachable = distance == .Nearby
  }
  
  var setReachable: ReachableSetter? {
    didSet {
      setReachable?(reachable)
    }
  }
}
