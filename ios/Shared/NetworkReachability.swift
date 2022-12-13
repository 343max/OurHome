import Foundation
import SystemConfiguration

class NetworkReachability: ReachabilityProvider {
  private let reachability: SCNetworkReachability
  private var reachable = false {
    didSet {
      setReachable?(reachable)
    }
  }
  
  var setReachable: ReachableSetter? = nil {
    didSet {
      setReachable?(reachable)
    }
  }
  
  // Queue where the `SCNetworkReachability` callbacks run
  private let queue = DispatchQueue.main
  
  required convenience init(distance: Distance, home: Home) {
    switch distance {
    case .Nearby:
      self.init(hostName: home.localNetworkHost.host!)
    case .Remote:
      self.init(hostName: home.externalHost.host!)
    }
  }
  
  init(hostName: String) {
    self.reachability = SCNetworkReachabilityCreateWithName(nil, hostName)!
    self.start()
  }
  
  private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
    let isReachable = flags.contains(.reachable)
    let connectionRequired = flags.contains(.connectionRequired)
    let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
    let canConnectWithoutIntervention = canConnectAutomatically && !flags.contains(.interventionRequired)
    return isReachable && (!connectionRequired || canConnectWithoutIntervention)
  }
  
  func checkConnection() {
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability, &flags)
    
    self.reachable = isNetworkReachable(with: flags)
  }
  
  // Flag used to avoid starting listening if we are already listening
  private var isListening = false

  // Starts listening
  func start() {
    // Checks if we are already listening
    guard !isListening else { return }

    // Creates a context
    var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
    // Sets `self` as listener object
    context.info = UnsafeMutableRawPointer(Unmanaged<NetworkReachability>.passUnretained(self).toOpaque())

    let callbackClosure: SCNetworkReachabilityCallBack? = {
      (reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
      guard let info = info else { return }

      Task {
        // Gets the `Handler` object from the context info
        let handler = Unmanaged<NetworkReachability>.fromOpaque(info).takeUnretainedValue()
        handler.checkConnection()
      }
    }

    // Registers the callback. `callbackClosure` is the closure where we manage the callback implementation
    if !SCNetworkReachabilitySetCallback(reachability, callbackClosure, &context) {
      // Not able to set the callback
    }

    // Sets the dispatch queue which is `DispatchQueue.main` for this example. It can be also a background queue
    if !SCNetworkReachabilitySetDispatchQueue(reachability, queue) {
      // Not able to set the queue
    }

    // Runs the first time to set the current flags
    queue.async {
      self.checkConnection()
    }

    isListening = true
  }
  
  // Stops listening
  func stop() {
    // Skips if we are not listening
    guard isListening
      else { return }

    // Remove callback and dispatch queue
    SCNetworkReachabilitySetCallback(reachability, nil, nil)
    SCNetworkReachabilitySetDispatchQueue(reachability, nil)

    isListening = false
  }

}
