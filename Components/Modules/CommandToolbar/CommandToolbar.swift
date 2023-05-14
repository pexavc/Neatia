import Granite
import SandKit
import Foundation

struct CommandToolbar: GraniteComponent {
    @Command var center: Center
    
    @Relay var sand: SandService
    @Relay var prompts: PromptService
    
    var prompt: BasicPrompt {
        prompts.prompt(sand.state.commandSet) ?? Prompts.Empty()
    }
    
    var command: String {
        sand.state.commandSet ?? "UNKNOWN"
    }
    
    var indexOfSCSelected: CGFloat {
        CGFloat(
            (prompt.subCommands.count - 1) - (prompt.subCommands.firstIndex(where: { $0.id == state.scSelected }) ?? 0)
        )
    }
    
    var subcommandValues: [SubcommandValue] {
        print("[CommandToolbar] selected sc: \(state.scSelected)")
        if let subcommand = prompt.subcommandFor(id: state.scSelected),
           let setSubCommand = sand.state.subCommandSet?[subcommand.id]?.value.id {
            print("[CommandToolbar] value set: \(setSubCommand)")
            return subcommand.values.filter { $0.id != setSubCommand }
        } else {
            return []
        }
    }
}
