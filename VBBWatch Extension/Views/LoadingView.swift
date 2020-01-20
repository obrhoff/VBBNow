import SwiftUI

struct LoadingView: View {
    @State private  var animate = false
    @State var strokeWidth: CGFloat = 4
    @State var duration: TimeInterval = 1.25
    @State var strokeBackgroundColor: Color = .clear
    @State var lineColor: Color = .white

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.purple, lineWidth: strokeWidth)
                .opacity(0.2)

            Circle()
                .trim(from: 1 / 8, to: 1 / 2)
                .stroke(lineColor, lineWidth: strokeWidth)
                .rotationEffect(.degrees(animate ? 1 : -360), anchor: .center)
                .animation(Animation.linear(duration: duration).repeatForever(autoreverses: false))
        }
        .padding(2)
        .drawingGroup()
        .onAppear {
            self.animate.toggle()
        }
    }
}
