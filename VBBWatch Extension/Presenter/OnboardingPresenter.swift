import Combine
import Foundation
import SwiftUI
import VBBFramework

final class OnboardingPresenter: ObservableObject {
    enum Page: Int, CaseIterable, Identifiable {
        case welcome
        case description
        case permission

        var id: Int {
            return rawValue
        }
    }

    @Published var currentPage: Page = .welcome
    let locationManager = CLLocationManager()

    func next() {
        switch currentPage {
        case .welcome:
            currentPage = .description
        case .description, .permission:
            currentPage = .permission
        }
    }
}
