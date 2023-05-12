import Granite
import SwiftUI
import SandKit

extension SandService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var query: String = ""
            var response: String = ""
            
            var isResponding: Bool = false
            
            var commandAutoComplete: [String] = []
            
            var commandSet: Prompts? = nil
            var subCommandSet: [String: Prompts.Subcommand]? = nil
            var subCommandFileSet: [String: [String: URL]]? = nil
            var lastError: Error? = nil {
                didSet {
                    errorExists = lastError != nil
                }
            }
            
            var errorExists: Bool = false
            
            var isCommandSet: Bool {
                commandSet != nil
            }
            
            var tokenCount: Int {
                SandGPT.shared.gpt3Tokenizer.encoder.enconde(text: query).count
            }
        }
        
        @Event public var ask: Ask.Reducer
        @Event public var activateCommands: ActivateCommands.Reducer
        @Event public var setCommand: SetCommand.Reducer
        @Event public var setSubCommand: SetSubCommand.Reducer
        @Event public var setSubCommandFile: SetSubCommandFile.Reducer
        
        @Event public var reset: Reset.Reducer
        
        @Store public var state: State
    }
    
    struct Error: GraniteModel {
        var message: String
    }
}
