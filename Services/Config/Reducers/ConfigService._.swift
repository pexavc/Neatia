import Granite
import CryptoKit
import MarqueKit
import SwiftUI
import Foundation

extension ConfigService {
    struct Hotkey: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            let key: InteractionManager.HotkeyOptions
            let kind: InteractionManager.Kind
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            switch meta.kind {
            case .mount:
                state.mountHotkey = meta.key
                InteractionManager.shared.registerHotkey(meta.key)
            case .promptStudio:
                state.promptStudioHotkey = meta.key
                InteractionManager.shared.registerHotkey(meta.key, kind: .promptStudio)
            }
        }
    }
    
    struct SetCustomAPIKey: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            let key: String
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta,
                  meta.key.newlinesSanitized.isNotEmpty else { return }
            
            let imageData = SandGPT.global_key_encoder(meta.key)
            
            print("[ConfigService] encoded \(imageData.count)")
            
            state.customAPIKey = imageData
            
            SandGPT.shared.CUSTOM_API_KEY = state.customAPIKey
            SandGPT.shared.useCustomAPI()
        }
    }
    
    struct RemoveCustomAPIKey: GraniteReducer {
        typealias Center = ConfigService.Center
        
        func reduce(state: inout Center.State) {
            state.customAPIKey = nil
            
            SandGPT.shared.CUSTOM_API_KEY = nil
            SandGPT.shared.useMainAPI()
        }
    }
    
    //WIP
    struct History: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            let query: String
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
        }
    }
}

