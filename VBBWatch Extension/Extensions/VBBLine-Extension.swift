import Foundation
import SwiftUI
import UIKit
import VBBFramework

extension VBBLineType {
    var assetsName: String {
        switch self {
        case .sBahn:
            return "SBahn"
        case .uBahn:
            return "UBahn"
        case .tram:
            return "Tram"
        case .bus:
            return "Bus"
        case .metro:
            return "Metro"
        case .bahn:
            return "Train"
        @unknown default:
            fatalError()
        }
    }
}
