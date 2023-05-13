import Granite
import SwiftUI

struct Config: GraniteComponent {
    @Command var center: Center
    
    @Relay var account: AccountService
    @Relay var config: ConfigService
    
    @SharedObject("nyc.stoic.Neatia.WindowVisibilityManager") var windowVisibility: WindowVisibilityManager
    @SharedObject("nyc.stoic.Neatia.SessionManager") var session: SessionManager
}
