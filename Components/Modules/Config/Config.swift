import Granite
import SwiftUI

struct Config: GraniteComponent {
    @Command var center: Center
    
    @Relay var account: AccountService
    @Relay var config: ConfigService
}
