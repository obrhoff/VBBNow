import SwiftUI
import VBBFramework

struct DepartureListView: View {
    @ObservedObject var presenter: DepartureListPresenter

    var body: some View {
        Group {
            if !self.presenter.stations.isEmpty {
                self.listView
            } else if self.presenter.status == .loading {
                self.loadingView
            } else {
                self.emptyView
            }
        }.navigationBarTitle("VBBNow").onAppear {
            self.presenter.didBecomeActive()
        }.contextMenu(menuItems: {
            Button(action: {
                self.presenter.update()
            }, label: {
                VStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                    Text("STATUS_RELOAD")
                }
            })
        })
    }
}

private extension DepartureListView {
    var listView: some View {
        List {
            Group {
                if self.presenter.isLoading {
                    HStack(alignment: .center) {
                        Spacer()
                        LoadingView(strokeBackgroundColor: .clear,
                                    lineColor: .white)
                            .frame(width: 22, height: 22, alignment: .center)
                        Spacer()
                    }
                }

                ForEach(self.presenter.stations) { (station: VBBStation) in
                    Section(header: Text(station.stationName)
                        .font(.footnote)) {
                        ForEach(self.presenter.departures(station)) { (departure: VBBDepature) in
                            NavigationLink(destination: LineView(presenter: LinePresenter(departure: departure))) {
                                DepartureView(presenter: DeparturePresenter(departure: departure))
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        }.navigationBarTitle(Text(station.stationName))
                    }
                }

            }.listRowPlatterColor(.clear)

        }.listStyle(CarouselListStyle())
    }

    var loadingView: some View {
        VStack {
            LoadingView(strokeBackgroundColor: .clear, lineColor: .white)
                .frame(width: 22, height: 22, alignment: .center)
            Text(self.loadingTitle)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
    }

    var emptyView: some View {
        VStack {
            Image(systemName: "location.slash.fill")
                .font(.title)
                .foregroundColor(.primary)

            Text("NO_STATIONS")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    var loadingTitle: String {
        switch presenter.status {
        case .finished:
            return presenter.location?.address ?? presenter.status.statusText
        default:
            return presenter.status.statusText
        }
    }
}

#if DEBUG
    struct DepartureList_Previews: PreviewProvider {
        static var previews: some View {
            DepartureListView(presenter: DepartureListPresenter())
        }
    }
#endif
