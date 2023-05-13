import Granite
import SwiftUI

extension PromptService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var customPrompts: [CustomPrompt] = []
        }
        
        @Store(persist: "neatia.persistence.prompt.0000", autoSave: true) public var state: State
    }
    
    static var maxTokenCount: Int {
        1200
    }
}
