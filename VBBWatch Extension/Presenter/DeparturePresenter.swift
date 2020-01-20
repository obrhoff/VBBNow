import Combine
import Foundation
import SwiftUI
import VBBFramework

final class DeparturePresenter: ObservableObject {
    var objectWillChange = PassthroughSubject<Void, Never>()
    var timeMinutesText: String = ""
    var timeUnitsText: String = ""
    var lineEnd: String = ""
    var lineName: String = ""
    var stationName: String = ""
    var timer: Timer?

    var lineImage: Image?
    var lineType: VBBLineType = .bahn
    var departure: VBBDepature?
    var station: VBBStation?

    init(departure: VBBDepature?) {
        self.departure = departure
        configureContent()
        configureTimer()
    }

    deinit {
        timer?.invalidate()
    }
}

private extension DeparturePresenter {
    func configureTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: .deparuteUpdateInterval, repeats: false, block: { [weak self] _ in
            self?.configureContent()
            self?.configureTimer()
        })
    }

    func configureContent() {
        station = departure?.station.firstObject() as? VBBStation
        lineType = departure?.line?.lineType() ?? .bus

        let assetName = VBBLine.assetName(for: lineType)
        let departureInterval = departure?.arrivalDate.timeIntervalSince(Date()) ?? 0
        let timeComponents = DateComponentsFormatter.time.string(from: departureInterval)?
            .components(separatedBy: " ") ?? [String]()

        stationName = station?.stationName ?? ""
        lineName = departure?.line?.lineName ?? ""
        lineImage = Image(assetName, bundle: Bundle.framework)
        lineEnd = "▶︎ \(departure?.line?.lineEnd ?? "Osloer Straße")"

        timeMinutesText = timeComponents.first ?? "2"
        timeUnitsText = timeComponents.last ?? "min"

        objectWillChange.send()
    }
}
