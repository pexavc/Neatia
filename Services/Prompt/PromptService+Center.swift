import Granite
import SwiftUI
import SandKit

extension PromptService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var customPrompts: [CustomPrompt] = []
        }
        
        @Event var create: Create.Reducer
        @Event var modify: Modify.Reducer
        @Event var delete: Delete.Reducer
        
        @Store(persist: "neatia.persistence.prompts.0002", autoSave: true) public var state: State
    }
    
    static var normalPromptMaxTokenCount: Int {
        2000
    }
    
    static var systemPromptMaxTokenCount: Int {
        1200
    }
    
    static var customPromptMaxTokenCount: Int {
        1200
    }
    
    func maxTokenCount(_ command: String?) -> Int {
        if let prompt = prompt(command) {
            return prompt.maxTokens
        } else {
            return PromptService.normalPromptMaxTokenCount
        }
    }
    
    var commands: [String] {
        customCommands.map { $0.capitalized } + systemPromptsRaw
    }
    
    var customCommands: [String] {
        state.customPrompts.map({ $0.command }).map({ $0.command.lowercased() })
    }
    
    var systemPrompts: [Prompts] {
        Prompts.allCases
    }
    
    var systemPromptsRaw: [String] {
        systemPrompts.map { $0.rawValue.capitalized }
    }
    
    func prompt(_ command: String?) -> BasicPrompt? {
        guard let value = command else { return nil }
        if customCommands.contains(value.lowercased()) {
            return state.customPrompts.first(where: { $0.command.command.lowercased() == value.lowercased() })
        } else if let systemPrompt = Prompts.init(rawValue: value.lowercased()) {
            return Prompts.all[systemPrompt]
        } else {
            return nil
        }
    }
}
