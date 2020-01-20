
import Combine
import SwiftUI
import VBBFramework

struct ParentView: View {
    @ObservedObject var presenter: ParentPresenter

    var body: some View {
        Group {
            if presenter.permission == .authorizedWhenInUse {
                DepartureListView(presenter: DepartureListPresenter())
            } else {
                OnboardingView()
            }
        }.animation(.default)
    }
}

#if DEBUG
    struct ParentView_Previews: PreviewProvider {
        static var previews: some View {
            ParentView(presenter: ParentPresenter())
        }
    }
#endif
