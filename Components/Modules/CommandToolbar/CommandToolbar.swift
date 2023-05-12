import Granite
import SandKit
import Foundation

struct CommandToolbar: GraniteComponent {
    @Command var center: Center
    
    @Relay var sand: SandService
    
    var prompt: BasicPrompt {
        Prompts.all[sand.state.commandSet ?? .empty] ?? Prompts.Empty()
    }
    
    var promptType: Prompts {
        sand.state.commandSet ?? .empty
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
