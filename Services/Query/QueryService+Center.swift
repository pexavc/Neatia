import Granite
import SwiftUI

extension QueryService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var value: String = "" {
                didSet {
                    SandGPTTokenizerManager.update(value)
                }
            }
        }
        
        @Store public var state: State
    }
}
