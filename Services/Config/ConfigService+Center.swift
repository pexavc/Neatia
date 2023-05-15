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
            
            //API Key
            var customAPIKey: Data? = nil
            
            var isCustomAPIKeySet: Bool {
                customAPIKey != nil
            }
            
            //History
            var storeHistory: Bool = false
            
            //Remote
            var isSettingsActive: Bool = false {
                didSet {
                    if isSettingsActive {
                        isDataPrivacyTabActive = false
                        isAccountTabActive = false
                    }
                }
            }
            var isDataPrivacyTabActive: Bool = false {
                didSet {
                    if isDataPrivacyTabActive {
                        isAccountTabActive = false
                        isSettingsActive = false
                    }
                }
            }
            var isAccountTabActive: Bool = true {
                didSet {
                    if isAccountTabActive {
                        isDataPrivacyTabActive = false
                        isSettingsActive = false
                    }
                }
            }
        }
        
        @Event var updateHotkey: Hotkey.Reducer
        @Event var setAPIKey: SetCustomAPIKey.Reducer
        
        @Store(persist: "neatia.persistence.config.0012", autoSave: true) public var state: State
    }
    
    static func encrypt(c: Character, key: Character) -> String? {
        let byte = [c.utf8() ^ key.utf8()]
        return String(bytes: byte, encoding: .utf8)
    }
     
    static func encryptDecrypt(message: String, key: String) -> String {
        return zip(message, key).compactMap { encrypt(c: $0.0, key: $0.1) }.joined()
    }
    
    static var secret: String {
        "ialrughbdjilajbvkWERVRUBN35bsdfgs"
    }
}

fileprivate extension Character {
    func utf8() -> UInt8 {
        let utf8 = String(self).utf8
        return utf8[utf8.startIndex]
    }
}
