#if os(iOS)

import Foundation
import SwiftUI

public struct GraniteModalContainerView : View {
    
    @EnvironmentObject var manager : GraniteModalManager
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            ForEach(manager.presenters.indices, id: \.self) { index in
                manager.presenters[index].backgroundView
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(Double(index))
                    .environmentObject(manager)

                manager.presenters[index].modalView
                    .zIndex(100.0 + Double(index))
            }
        }
        
    }
    
}

#endif
