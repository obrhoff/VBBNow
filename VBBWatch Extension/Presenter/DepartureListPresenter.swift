import Combine
import CoreLocation
import Foundation
import SwiftUI
import VBBFramework

final class DepartureListPresenter: NSObject, ObservableObject {
    var objectWillChange = PassthroughSubject<Void, Never>()
    private let networkManager = VBBNetworkManager()
    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private var lastFetch: Date?
    private var observer: NSKeyValueObservation?

    private var departures: [VBBStation: [VBBDepature]] = [:]

    @Published var stations: [VBBStation] = [] {
        didSet {
            objectWillChange.send()
        }
    }

    @Published var location: VBBLocation? {
        didSet {
            objectWillChange.send()
        }
    }

    var status: VBBNetworkStatus {
        return networkManager.status
    }

    var isLoading: Bool {
        let states: [VBBNetworkStatus] = [.geocoding, .loading, .loadingDetails]
        return states.contains(self.status)
    }

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: .active, object: nil)

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers

        configureTimer()
        updateProperties()
        observer = networkManager.observe(\.status) { [weak self] _, _ in
            DispatchQueue.main.async { self?.objectWillChange.send() }
        }
    }

    func update() {
        locationManager.requestLocation()
    }

    @objc func didBecomeActive() {
        updateProperties()

        let lastTimeInterval = fabs(lastFetch?.timeIntervalSinceNow ?? 0)
        if lastTimeInterval > .backgroundInterval {
            fetch()
        }
    }

    deinit {
        timer?.invalidate()
        observer?.invalidate()
    }
}

extension DepartureListPresenter {
    func departures(_ station: VBBStation) -> [VBBDepature] {
        return departures[station] ?? []
    }
}

private extension DepartureListPresenter {
    func updateProperties() {
        guard let location = VBBPersistanceManager.manager.storedLocation else {
            return
        }

        let stations = VBBStation.sort(byRelevance: location, andLimit: 3)
        stations.forEach { station in
            let lines = station.lines.mapItems().compactMap { $0 as? VBBLine }
            var departures = lines.compactMap {
                $0.departures.mapItems().compactMap { $0 as? VBBDepature }
                    .sorted(by: { (firstDeparture, secondDeparture) -> Bool in
                        firstDeparture.arrivalDate < secondDeparture.arrivalDate
                    }).filter {
                        $0.arrivalDate > Date()
                    }.first
            }

            departures.sort { (firstDeparture, secondDeparture) -> Bool in
                let firstType = firstDeparture.line?.lineType() ?? .uBahn
                let secondType = secondDeparture.line?.lineType() ?? .uBahn
                let firstArrival = firstDeparture.arrivalDate
                let secondArrival = secondDeparture.arrivalDate
                return firstType == secondType ? firstArrival < secondArrival : firstType.rawValue < secondType.rawValue
            }

            self.departures[station] = departures
        }

        self.stations = stations
    }

    func fetch() {
        let storedLocation = VBBPersistanceManager.manager.storedLocation
        let currentLocation = locationManager.location ?? storedLocation?.location

        guard let location = currentLocation, status == .finished || status == .failed else {
            return
        }

        networkManager.fetchNearedStations(location) { [weak self] _, location in
            guard let location = location else {
                return
            }
            self?.lastFetch = Date()
            self?.location = location
            self?.updateProperties()
        }
    }

    func configureTimer() {
        let components = Calendar.current.component(.second, from: Date())
        let refreshInterval = 60.0 - TimeInterval(components) + 1

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: false, block: { [weak self] _ in
            self?.updateProperties()
            self?.configureTimer()
        })
    }
}

extension DepartureListPresenter: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        fetch()
    }

    func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        fetch()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        manager.requestLocation()
    }
}
