import Granite
import SwiftUI
import LaunchAtLogin
import MarqueKit
import SandKit

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
            
            //Config
            var customPromptConfigEnabled: Bool = false
            var customPromptConfig: PromptConfig = .init()
            
            //API Key
            var customAPIKey: [UInt32]? = nil
            
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
        @Event var removeAPIKey: RemoveCustomAPIKey.Reducer
        
        @Store(persist: "neatia.persistence.config.0013", autoSave: true, preload: true) public var state: State
    }
    
    static func decode(_ bytes: [UInt32]) -> String? {
        let result = MarqueKit().searchBytes(bytes)
        guard let payload = result.payload.components(separatedBy: "<m12>").filter({ $0.isNotEmpty }).first?.components(separatedBy: "</m12>").first else {
            return nil
        }
        
        if let decodedData = Data(base64Encoded: payload),
           let decodedString = String(data: decodedData, encoding: .utf8) {
            return decodedString
        } else {
            return nil
        }
    }
}

fileprivate extension Character {
    func utf8() -> UInt8 {
        let utf8 = String(self).utf8
        return utf8[utf8.startIndex]
    }
}
