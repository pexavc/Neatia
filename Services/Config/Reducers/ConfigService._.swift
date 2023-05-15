import Granite
import CryptoKit

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
    
    //WIP
    struct SetCustomAPIKey: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            let key: String
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            let encrypted = ConfigService.encryptDecrypt(message: meta.key, key: ConfigService.secret)
            
            
            state.customAPIKey = encrypted.data(using: .utf8)
            SandGPT.shared.CUSTOM_API_KEY = state.customAPIKey
            SandGPT.shared.useCustomAPI()
        }
        
        func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
            let privateKey = P256.KeyAgreement.PrivateKey()
            return privateKey
        }
        
        func exportPrivateKey(_ privateKey: P256.KeyAgreement.PrivateKey) -> String? {
            let rawPrivateKey = privateKey.rawRepresentation
            let privateKeyBase64 = rawPrivateKey.base64EncodedString()
            guard let percentEncodedPrivateKey = privateKeyBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else { return nil }
            return percentEncodedPrivateKey
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
