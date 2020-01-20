import Combine
import Foundation
import SwiftUI
import VBBFramework

struct OnboardingView: View {
    @ObservedObject var presenter: OnboardingPresenter

    init(presenter: OnboardingPresenter = OnboardingPresenter()) {
        self.presenter = presenter
    }

    var body: some View {
        ScrollView {
            ZStack {
                ForEach([self.presenter.currentPage]) { page in
                    OnboardingPageView(title: page.title,
                                       subtitle: page.subtitle,
                                       buttonTitle: page.buttonTitle,
                                       lineType: page.lineType) {
                        switch page {
                        case .welcome, .description:
                            self.presenter.next()
                        case .permission:
                            self.presenter.locationManager.requestWhenInUseAuthorization()
                        }
                    }
                }.transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }
}

struct OnboardingPageView: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let buttonTitle: LocalizedStringKey
    let lineType: VBBLineType
    let primaryAction: () -> Void

    init(title: LocalizedStringKey, subtitle: LocalizedStringKey, buttonTitle: LocalizedStringKey, lineType: VBBLineType, primaryAction: @escaping (() -> Void)) {
        self.title = title
        self.subtitle = subtitle
        self.lineType = lineType
        self.buttonTitle = buttonTitle
        self.primaryAction = primaryAction
    }

    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(.primary)
                .font(.system(size: 24, design: .rounded))
                .bold()

            Text(subtitle)
                .foregroundColor(.secondary)
                .font(.body)
                .multilineTextAlignment(.center)

            Button(action: self.primaryAction) {
                Text(self.buttonTitle)
            }.gradientColor(self.lineType)
        }.padding()
    }
}

private extension OnboardingPresenter.Page {
    var title: LocalizedStringKey {
        switch self {
        case .welcome, .description:
            return "VBBNOW_TITLE"
        case .permission:
            return "VBBNOW_TITLE_PERMISSIONS"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .welcome:
            return "VBBNOW_INTRODUCTION_TEXT"
        case .description:
            return "VBBNOW_INTRODUCTION_DETAIL_TEXT"
        case .permission:
            return "VBBNOW_INTRODUCTION_PERMISSION_TEXT"
        }
    }

    var buttonTitle: LocalizedStringKey {
        switch self {
        case .welcome, .description:
            return "NEXT"
        case .permission:
            return "ALLOW"
        }
    }

    var lineType: VBBLineType {
        switch self {
        case .welcome:
            return .uBahn
        case .permission:
            return .bus
        case .description:
            return .tram
        }
    }
}

#if DEBUG
    struct OnboardingView_Previews: PreviewProvider {
        static var previews: some View {
            OnboardingView()
        }
    }

    struct OnboardingPageView_Previews: PreviewProvider {
        static var previews: some View {
            OnboardingPageView(title: "Title",
                               subtitle: "This is a title with nothing to mean",
                               buttonTitle: "Text", lineType: .metro,
                               primaryAction: {})
        }
    }
#endif
