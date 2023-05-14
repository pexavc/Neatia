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
            var mountHotkey: InteractionManager.HotkeyOptions = .n
            var promptStudioHotkey: InteractionManager.HotkeyOptions = .p
            
            //History
            var storeHistory: Bool = false
        }
        
        @Event var updateHotkey: Hotkey.Reducer
        
        @Store(persist: "neatia.persistence.config.0008", autoSave: true) public var state: State
    }
}
