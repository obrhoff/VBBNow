import Foundation
import SwiftUI
import VBBFramework

struct DepartureView: View {
    @ObservedObject var presenter: DeparturePresenter

    var body: some View {
        HStack(alignment: .center) {
            (Text(presenter.timeMinutesText)
                .font(.system(size: 24, design: .rounded)).bold() +
                Text("\n") +
                Text(presenter.timeUnitsText).font(.subheadline))
                .multilineTextAlignment(.center)
            Divider()
            VStack(alignment: .leading, spacing: 2) {
                Text(presenter.lineName)
                    .font(.system(size: 26, design: .rounded))
                    .bold()
                    .minimumScaleFactor(0.8)
                Divider()
                Text(presenter.lineEnd)
                    .font(.system(size: 16, design: .default))
                    .lineLimit(3)
                    .truncationMode(.tail)
            }
        }
        .padding()
        .frame(idealWidth: 90)
        .gradientColor(presenter.lineType)
        .drawingGroup()
    }
}

#if DEBUG
    struct DepartureView_Previews: PreviewProvider {
        static var previews: some View {
            DepartureView(presenter: DeparturePresenter(departure: nil))
        }
    }
#endif
