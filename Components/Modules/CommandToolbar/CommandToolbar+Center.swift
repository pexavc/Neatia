import Granite
import SwiftUI

extension CommandToolbar {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var scSelected: String = ""
            var toggleDropdown: Bool = false
            var showAlert: Bool = false
        }
        
        @Store public var state: State
    }
}
