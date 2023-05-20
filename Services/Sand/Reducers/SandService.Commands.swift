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
            
            var commandComponents: [String] = []
            if meta.reset {
                state.commandSet = nil
            } else {
                let components = meta.value.lowercased().components(separatedBy: " ").map { $0.newlinesSanitized }
                
                //Setup main command
                if let first = components.first,
                   first.hasPrefix("/"),
                   let firstCommand = first.lowercased().suggestions(state.commandAutoComplete).first {
                    
                    //Setup Command toolbar
                    environment
                        .center
                        .commandToolbarActivated
                        .send(
                            EnvironmentService
                                .CommandToolbarActivated
                                .Meta(isActive: meta.reset == false))
                    
                    state.commandSet = firstCommand.lowercased().replacingOccurrences(of: "/", with: "")
                    
                    commandComponents = components
                }
            }
            
            //When command menu is shown tokenizer is paused so we unpause it
            SandGPTTokenizerManager.shared.pause = false
            
            //Setup subcommands
            state.subCommandSet = [:]
            state.subCommandFileSet = [:]
            
            var subCommandSet: Bool = false
            
            if commandComponents.count > 1,
               commandComponents[1].newlinesSanitized.lowercased().isNotEmpty == true {
                if let basic = prompts.prompt(state.commandSet) {
                    let second = commandComponents[1].newlinesSanitized.lowercased()
                   
                    let scVs = basic.subCommands.compactMap({ scV in
                        
                        var dict: [String : Any] = [:]
                        dict["subcommand"] = scV
                        dict["subcommandValue"] = scV.values.first(where: {
                            let range = $0.id.lowercased().range(of: second.lowercased())
                            
                            if let rangeCheck = range {
                                return rangeCheck.lowerBound == $0.id.startIndex
                            } else {
                                return false
                            }
                            
                        })
                        
                        return dict
                    })
                    
                    if let scV = scVs.first {
                        if let sc = scV["subcommand"] as? (any AnySubcommand),
                           let value = scV["subcommandValue"] as? SubcommandValue {
                            print("{TEST} set \(sc)")
                            state.subCommandSet?[sc.id] = Prompts.subCommand(sc, scValue: value)
                            state.subCommandFileSet?[sc.id] = [:]
                            subCommandSet = true
                        }
                    }
                }
            }
            
            if subCommandSet == false,
               let command = state.commandSet {
                if let basic = prompts.prompt(command) {
                    
                    for subcommand in basic.subCommands {
                        if let value = subcommand.values.first {
                            state.subCommandSet?[subcommand.id] = Prompts.subCommand(subcommand, scValue: value)
                            state.subCommandFileSet?[subcommand.id] = [:]
                        }
                    }
                }
            }
            
            query.center.$state.binding.value.wrappedValue = ""
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
