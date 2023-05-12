import Granite
import SandKit

struct Query: GraniteComponent {
    @Command var center: Center
    
    @Relay var environment: EnvironmentService
    @Relay var account: AccountService
    @Relay var sand: SandService
    
    //TODO: could be a better way to generate helper text, a "smarter" way. But for now order matters in SandKit
    var helperText: String {
        if var helperText = sand.state.commandSet?.basic.subCommandHelperText {
            if let scValues = sand.state.subCommandSet?.values {
                for value in scValues {
                    helperText += value.value.additionalHelperText ?? ""
                }
                return helperText.isEmpty ? "Type something" : helperText
            } else {
                return helperText.isEmpty ? "Type something" : helperText
            }
        } else {
            return "Type something"
        }
    }
}
