import Granite
import SandKit
import Foundation
import PDFKit

extension SandService {
    struct ActivateCommands: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let isActive: Bool
        }
        
        @Payload var meta: Meta?
        
        @Relay var environment: EnvironmentService
        @Relay var prompts: PromptService
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            guard state.commandSet == nil else { return }
            
            environment
                .center
                .commandMenuActivated
                .send(
                    EnvironmentService
                        .CommandMenuActivated
                        .Meta(isActive: meta.isActive))
            
            SandGPTTokenizerManager.shared.pause = meta.isActive
            
            if meta.isActive {
                state.commandAutoComplete = prompts.commands
            } else {
                state.commandAutoComplete = []
            }
        }
    }
    
    struct SetCommand: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let value: String
            let reset: Bool
        }
        
        @Payload var meta: Meta?
        
        @Relay var environment: EnvironmentService
        @Relay var prompts: PromptService
        @Relay var query: QueryService
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            environment
                .center
                .commandToolbarActivated
                .send(
                    EnvironmentService
                        .CommandToolbarActivated
                        .Meta(isActive: meta.reset == false))
            
            state.commandSet = meta.reset ? nil : meta.value.lowercased().replacingOccurrences(of: "/", with: "")
            
            SandGPTTokenizerManager.shared.pause = false
            
            if let command = state.commandSet {
                if let basic = prompts.prompt(command) {
                    state.subCommandSet = [:]
                    state.subCommandFileSet = [:]
                    
                    for subcommand in basic.subCommands {
                        if let value = subcommand.values.first {
                            state.subCommandSet?[subcommand.id] = Prompts.subCommand(subcommand, scValue: value)
                            state.subCommandFileSet?[subcommand.id] = [:]
                        }
                    }
                }
                
                query.center.$state.binding.value.wrappedValue = ""
            }
        }
    }
}

extension String {
    func suggestions(_ options: [String]) -> [String] {
        guard self.count > 1 else  { return [] }
        
        let text = self
        
        let textAfterCommand: String = String(text[text.index(after: text.startIndex)...])

        let isUppercased: Bool = textAfterCommand.first?.isUppercase == true
       
        let suggestions: [String] = options
            .filter {
                let range = $0.lowercased().range(of: textAfterCommand.lowercased())
                
                if let rangeCheck = range {
                    return rangeCheck.lowerBound == $0.startIndex
                } else {
                    return false
                }
                
            }.map {
                if isUppercased {
                    return ("/"+$0).capitalized
                } else {
                    return ("/"+$0).lowercased()
                }
            }
        
        return suggestions
    }
}
