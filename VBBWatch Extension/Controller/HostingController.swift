import CoreLocation
import Foundation
import SwiftUI
import VBBFramework
import WatchKit

class HostingController: WKHostingController<ParentView> {
    override init() {
        super.init()
    }

    override var body: ParentView {
        return ParentView(presenter: ParentPresenter())
    }
}
