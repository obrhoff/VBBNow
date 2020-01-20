import Combine
import CoreLocation
import Foundation
import SwiftUI
import VBBFramework

final class ParentPresenter: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    var objectWillChange = PassthroughSubject<Void, Never>()

    @Published var permission: CLAuthorizationStatus = .notDetermined {
        didSet {
            objectWillChange.send(())
        }
    }

    public override init() {
        super.init()
        permission = CLLocationManager.authorizationStatus()
        locationManager.delegate = self
    }
}

extension ParentPresenter: CLLocationManagerDelegate {
    public func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        permission = status
    }
}
