import Foundation

extension NSNotification.Name {
    static let active = NSNotification.Name("applicationDidBecomeActive")
    static let resign = NSNotification.Name("applicationWillResignActive")
}
