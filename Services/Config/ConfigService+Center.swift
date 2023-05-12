import Granite
import SwiftUI
import LaunchAtLogin

extension ConfigService {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            var showVisualGuide: Bool = false
            
            //Launch
            var launchAtLogin: Bool = false {
                didSet {
                    LaunchAtLogin.isEnabled = launchAtLogin
                }
            }
            
            //Hotkeys
            var mountHotkey: InteractionManager.HotkeyOptions = .s
        }
        
        @Event var updateHotkey: Hotkey.Reducer
        
        @Store(persist: "sina.persistence.config.0004", autoSave: true) public var state: State
    }
}
