import Foundation
import Network
import Observation

/// Reports whether the device currently has a usable network path.
@MainActor
protocol ConnectivityMonitoring: AnyObject {
    var isConnected: Bool { get }
}

/// `ConnectivityMonitoring` backed by `NWPathMonitor`.
@MainActor
@Observable
final class NetworkMonitor: ConnectivityMonitoring {

    // MARK: - Properties

    private(set) var isConnected = true

    @ObservationIgnored private let monitor = NWPathMonitor()

    // MARK: - Init

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            // NWPathMonitor reports on its own queue; observable state must only change on the main actor.
            Task { @MainActor in
                self?.isConnected = isConnected
            }
        }
        monitor.start(queue: DispatchQueue(label: "devpedrovillalba.Xfaixa.NetworkMonitor"))
    }

    isolated deinit {
        monitor.cancel()
    }
}

/// Fixed `ConnectivityMonitoring` for previews and tests; flip `isConnected` to simulate changes.
@MainActor
@Observable
final class StaticConnectivityMonitor: ConnectivityMonitoring {
    var isConnected: Bool

    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }
}
