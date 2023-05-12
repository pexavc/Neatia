import Granite
import SwiftUI

extension ShortcutBar {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            
        }
        
        @Store public var state: State
    }
}
