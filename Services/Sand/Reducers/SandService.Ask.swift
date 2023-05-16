import Granite
import SandKit
import Foundation

extension SandService {
    struct Ask: GraniteReducer {
        typealias Center = SandService.Center
        
        @Event var received: AskResponse.Reducer
        
        @Relay var environment: EnvironmentService
        @Relay var prompts: PromptService
        @Relay var config: ConfigService
        
        func reduce(state: inout Center.State) {
            guard SandGPT.shared.isResponding == false else { return }
            
            let maxTokenCount: Int = prompts.maxTokenCount(state.commandSet)
            
            let systemPrompt: String? = nil
            
            state.lastError = nil
            
            let userPrompt: String
            
            let engineeredPrompt: BasicPrompt? = prompts.prompt(state.commandSet)
            
            //Prompt Generation
            if let command = state.commandSet,
               let prompt = engineeredPrompt {
                if SandGPTTokenizerManager.shared.kit.tokenCount > maxTokenCount {
                    state.lastError = .init(message: "Please reduce the amount of text in order reach the token count limit. You are currently at \(SandGPTTokenizerManager.shared.kit.tokenCount)/\(maxTokenCount)")
                    
                    return
                }
                
                if prompt.hasSubcommand == true,
                    let subcommands = state.subCommandSet?.values {
                    
                    //TODO: this would also be changed once (maybe) when subcommand system gets more sophisticated
                    if let firstScv = subcommands.filter({ $0.value.acceptsFile }).filter({ $0.value.fileContents.isEmpty }).first {
                        
                        state.lastError = .init(message: "Please upload a file type of \(firstScv.value.acceptedFileExtensions.map { $0.uppercased() }.joined(separator: ", ")).")
                        
                        return
                    }
                    
                    userPrompt = prompt.createWithSubCommand(state.query, subCommands: Array(subcommands))
                } else {
                    userPrompt = prompt.create(state.query)
                }
                print("[SandService] Using /\(command.capitalized) \(prompt.isSystemPrompt ? "" : "(custom)") ------------- ")
                print(prompt.debugDescription)
            } else {
                if SandGPTTokenizerManager.shared.kit.tokenCount > maxTokenCount {
                    state.lastError = .init(message: "Please reduce the amount of text in order reach the token count limit. You are currently at \(SandGPTTokenizerManager.shared.kit.tokenCount)/\(maxTokenCount)")
                    
                    return
                }
                
                userPrompt = state.query
                
                print("[SandService] Normal Query --------------------- ")
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
            
            print("[SandService] Command for prompt: \(state.commandSet)")
            print("[SandService] Use custom config: \(config.state.customPromptConfigEnabled)")
            
            SandGPT.shared.ask(userPrompt,
                               withSystemPrompt: systemPrompt,
                               withConfig: engineeredPrompt?.config ?? .init(),
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
