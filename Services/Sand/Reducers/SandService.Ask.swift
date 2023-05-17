import Granite
import SandKit
import Foundation
import Markdown

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
            
            state.lastError = nil
            
            let userPrompt: String
            
            let engineeredPrompt: BasicPrompt? = prompts.prompt(state.commandSet)
            
            let systemPrompt: String? = engineeredPrompt?.config.systemPrompt
            
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
            print("[SandService] Use System prompt: \(systemPrompt)")
            SandGPT.shared.ask(userPrompt,
                               withSystemPrompt: systemPrompt,
                               withConfig: engineeredPrompt?.config ?? .init(),
                               event: received)
        }
    }
    
    struct AskResponse: GraniteReducer {
        typealias Center = SandService.Center
        
        @Relay var environment: EnvironmentService
        
        @Payload var response: SandGPT.Response?
        
        //@Event var processDocument: AskDocumentResponse.Reducer
        
        func reduce(state: inout Center.State) {
            guard response?.isComplete == false else {
                print("[SandService] AskIsComplete")
                
                if response?.isStream == false {
                    if let payload = response, let data = payload.data {
                        //processDocument.send(payload)
                        let doc = Document(parsing: data, source: nil)
                        let lineCount = Int(doc.range?.upperBound.line ?? 0)
                        
                        environment
                            .center
                            .responseWindowSize
                            .send(
                                EnvironmentService
                                    .ResponseWindowSizeUpdated
                                    .Meta(lineCount: lineCount + (lineCount > 1 ? 2 : 0)))
                        
                        state.response = data
                        state.isResponding = false
                        
                    } else {
                        state.response = response?.data ?? ""
                    }
                } else {
                    state.isResponding = false
                }
                
                return
            }
            
            state.response = response?.data ?? ""
            //print("[SandService] Sending: \(state.response)")
        }
    }
    
    //Weird race condition in continued reducers? check issue#1 in granite
    struct AskDocumentResponse: GraniteReducer {
        typealias Center = SandService.Center
        
        @Relay var environment: EnvironmentService
        
        @Payload var response: SandGPT.Response?
        
        func reduce(state: inout Center.State) {
            guard let response = response?.data else { return }
            let doc = Document(parsing: response, source: nil)
            let lineCount = Int(doc.range?.upperBound.line ?? 0)
            
            environment
                .center
                .responseWindowSize
                .send(
                    EnvironmentService
                        .ResponseWindowSizeUpdated
                        .Meta(lineCount: lineCount + (lineCount > 1 ? 2 : 0)))
            
            state.response = response
            state.isResponding = false
        }
        
        var thread: DispatchQueue? {
            .main
        }
    }
}
