import Foundation
import Realm
import SwiftUI
import VBBFramework

struct LineView: View {
    @ObservedObject var presenter: LinePresenter

    var body: some View {
        List {
            ForEach(presenter.departures) { departure in
                DepartureView(presenter: DeparturePresenter(departure: departure))
                    .listRowPlatterColor(.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }.navigationBarTitle(Text(self.presenter.lineName))
    }
}

#if DEBUG
    struct LineView_Previews: PreviewProvider {
        static var previews: some View {
            LineView(presenter: LinePresenter(departure: nil))
        }
    }
#endif
