import Granite

struct CommandMenu: GraniteComponent {
    @Command var center: Center
    
    @Relay var sand: SandService
    @Relay var prompts: PromptService
}
