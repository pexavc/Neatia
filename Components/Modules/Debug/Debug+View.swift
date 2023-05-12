import Granite
import SwiftUI

extension Debug: View {
    public var view: some View {
        VStack {
            Spacer()
            Button(action: {
//                print("{TEST} \(holdings.state.strategy?.investments.count)")
            }) {
                GraniteButton(.text("Test"),
                              selected: true,
                              size: .init(16),
                              padding: .init(0,
                                             Brand.Padding.xMedium,
                                             Brand.Padding.xSmall,
                                             Brand.Padding.small))
            }
            Spacer()
        }
    }
}
