import Foundation
import VBBFramework
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        VBBPersistanceManager.trim()
    }

    func applicationDidBecomeActive() {
        NotificationCenter.default.post(name: .active, object: self)
    }

    func applicationWillResignActive() {
        NotificationCenter.default.post(name: .resign, object: self)
    }
}
