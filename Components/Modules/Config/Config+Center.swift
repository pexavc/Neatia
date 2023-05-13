import Granite
import SwiftUI

extension Config {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var isAccountTabActive: Bool = true
        }
        
        @Store public var state: State
    }
}
