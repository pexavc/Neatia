import Granite
import SwiftUI

extension EnvironmentService {
    struct Boot: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        @Relay var config: ConfigService
        
        @Event var hotkeyDetected: HotkeyDetected.Reducer
        
        func reduce(state: inout Center.State) {
            state.pane = .init(defaultSize: WindowComponent.Style.defaultWindowSize) {
                PaneView()
            }
            
            state.pane?.build()
            
            InteractionManager.shared.setHotkeyObserver(hotkeyDetected)
            InteractionManager.shared.registerHotkey(config.state.mountHotkey)
//            HotkeyManager.register()
        }
    }
}


