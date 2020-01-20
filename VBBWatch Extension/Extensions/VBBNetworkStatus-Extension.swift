import Foundation
import VBBFramework

extension VBBNetworkStatus {
    var statusText: String {
        let localizedKey: String
        switch self {
        case .geocoding:
            localizedKey = "STATUS_GEOCODING"
        case .loading:
            localizedKey = "STATUS_LOADING_STATIONS"
        case .loadingDetails:
            localizedKey = "STATUS_LOADING_STATIONS_DETAILS"
        case .failed:
            localizedKey = "STATUS_FAILED"
        default:
            localizedKey = "STATUS_LOADING_UNKNOWN"
        }
        return NSLocalizedString(localizedKey, comment: "")
    }
}
