import Granite
import SandKit
import SwiftUI

//API KEY: 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

struct Mount: GraniteComponent {
    @Command var center: Center
    
    @Relay var environment: EnvironmentService
    @Relay var account: AccountService
    @Relay var sand: SandService
    @Relay var config: ConfigService
    
    @SharedObject("nyc.stoic.Neatia.SessionManager") var session: SessionManager
}
