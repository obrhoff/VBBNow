import Combine
import Foundation
import Realm
import VBBFramework

final class LinePresenter: ObservableObject {
    var objectWillChange = PassthroughSubject<Void, Never>()
    var departures: [VBBDepature] = []
    var notificationToken: RLMNotificationToken?
    let lineName: String

    init(departure: VBBDepature?) {
        let station = departure?.station.firstObject() as? VBBStation
        lineName = station?.stationName ?? ""

        if let station = station {
            let predicate = NSPredicate(format: "scheduledDate > %@ AND (ANY station == %@)", NSDate(), station)
            let sortDescriptor = [RLMSortDescriptor(keyPath: #keyPath(VBBDepature.scheduledDate), ascending: true)]
            let results = VBBDepature.objects(with: predicate).sortedResults(using: sortDescriptor)
            notificationToken = results.addNotificationBlock { [weak self] results, _, _ in
                self?.departures = results?.mapItems().compactMap { $0 as? VBBDepature } ?? []
            }
        }
    }

    deinit {
        notificationToken?.invalidate()
    }
}
