import Granite
import SwiftUI

extension Debug {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            
        }
        
        @Store public var state: State
    }
}
