import Granite

struct Response: GraniteComponent {
    @Command var center: Center
    
    @Relay var environment: EnvironmentService
    @Relay var sand: SandService
    @Relay var config: ConfigService
        
}
