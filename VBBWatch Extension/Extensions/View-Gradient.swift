import Foundation
import SwiftUI
import VBBFramework

extension View {
    func gradientColor(_ type: VBBLineType,
                       cornerRadius _: CGFloat = 8.0,
                       intensity: Double = 0.7) -> some View {
        return gradientColor(Color(VBBLine.assetName(for: type), bundle: Bundle.framework),
                             intensity: intensity)
    }

    func gradientColor(_ color: Color,
                       cornerRadius: CGFloat = 8.0,
                       intensity: Double = 0.7) -> some View {
        background(LinearGradient(gradient: Gradient(colors: [color.opacity(intensity), color]),
                                  startPoint: .top, endPoint: .bottom))
            .background(Color.white)
            .cornerRadius(cornerRadius)
    }
}
