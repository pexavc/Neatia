import Granite
import SandKit
import Foundation

extension SandService {
    struct Ask: GraniteReducer {
        typealias Center = SandService.Center
        
        @Event var received: AskResponse.Reducer
        
        @Relay var environment: EnvironmentService
        
        func reduce(state: inout Center.State) {
            guard SandGPT.shared.isResponding == false else { return }
            
            let systemPrompt: String? = nil
            
//            if let command = state.commandSet {
//                systemPrompt = Prompts.all[command]?.prompt
//            } else {
//                systemPrompt = nil
//            }
            
            state.lastError = nil
            
            let prompt: String
            
            //Prompt Generation
            if let command = state.commandSet {
                if SandGPTTokenizerManager.shared.kit.tokenCount > command.maxTokens {
                    state.lastError = .init(message: "Please reduce the amount of text in order reach the token count limit. You are currently at \(SandGPTTokenizerManager.shared.kit.tokenCount)/\(SandService.maxTokenCount)")
                    
                    return
                }
                
                if Prompts.all[command]?.hasSubcommand == true,
                    let subcommands = state.subCommandSet?.values {
                    
                    //TODO: this would also be changed once (maybe) when subcommand system gets more sophisticated
                    if let firstScv = subcommands.filter({ $0.value.acceptsFile }).filter({ $0.value.fileContents.isEmpty }).first {
                        
                        state.lastError = .init(message: "Please upload a file type of \(firstScv.value.acceptedFileExtensions.map { $0.uppercased() }.joined(separator: ", ")).")
                        
                        return
                    }
                    
                    prompt = Prompts.all[command]?.createWithSubCommand(state.query, subCommands: Array(subcommands)) ?? state.query
                } else {
                    prompt = Prompts.all[command]?.create(state.query) ?? state.query
                }
            } else {
                if SandGPTTokenizerManager.shared.kit.tokenCount > SandService.maxTokenCount {
                    state.lastError = .init(message: "Please reduce the amount of text in order reach the token count limit. You are currently at \(SandGPTTokenizerManager.shared.kit.tokenCount)/\(SandService.maxTokenCount)")
                    
                    return
                }
                
                prompt = state.query
            }
            
            //UI
            //First time response is seen
            environment
                .center
                .responseWindowSize
                .send(
                    EnvironmentService
                        .ResponseWindowSizeUpdated
                        .Meta(lineCount: 1))
            
            state.response = ""
            state.isResponding = true
            
            //print("[SandService] Command for prompt: \(state.commandSet)")
            
            SandGPT.shared.ask(prompt,
                               withSystemPrompt: systemPrompt,
                               event: received)
        }
    }
    
    struct AskResponse: GraniteReducer {
        typealias Center = SandService.Center
        
        @Payload var response: SandGPT.Response?
        
        func reduce(state: inout Center.State) {
            guard response?.isComplete == false else {
                print("[SandService] AskIsComplete")
                state.isResponding = false
                return
            }
            
            state.response = response?.data ?? ""
            print("[SandService] Sending: \(state.response)")
        }
    }
}
