import Granite
import SwiftUI

extension Config {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var isAccountTabActive: Bool = true
            var isMountClosed: Bool = InteractionManager.shared.mountIsClosed
        }
        
        @Store public var state: State
    }
}
