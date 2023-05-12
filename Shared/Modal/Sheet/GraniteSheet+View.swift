#if os(iOS)

import Foundation
import SwiftUI

extension View {
    
    public func addGraniteSheet<Background : View>(_ manager : GraniteSheetManager, background : Background) -> some View {
        GraniteSheetContainerView(content: self, background: background)
            .environmentObject(manager)
    }
    
    public func addGraniteSheet(_ manager : GraniteSheetManager) -> some View {
        GraniteSheetContainerView(content: self, background: Color.black)
            .environmentObject(manager)
    }
}

#endif
