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
            
            guard let image = NSImage(named: "logo_small") else {
                return
            }
            
            guard let data = image.png else { return }
            
            let nsData = NSData(data: data)
            
            let bytes = getArrayOfBytesFromImage(imageData: nsData)
            
            let imageData = MarqueKit().encodeBytes(meta.key, withObject: bytes).data
            
            print("[ConfigService] encoded \(imageData.count)")
            
            state.customAPIKey = imageData
            
            SandGPT.shared.CUSTOM_API_KEY = state.customAPIKey
            SandGPT.shared.useCustomAPI()
        }
        
        func getArrayOfBytesFromImage(imageData:NSData) -> Array<UInt32> {
            // the number of elements:
            let count = imageData.length / MemoryLayout<UInt32>.size
            
            // create array of appropriate length:
            var bytes = [UInt32](repeating: 0, count: count)
            
            // copy bytes into array
            imageData.getBytes(&bytes, length:count * MemoryLayout<UInt32>.size)
            
            var byteArray:Array = Array<UInt32>()
            
            for i in 0 ..< count {
                byteArray.append(bytes[i])
            }
            
            return byteArray
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

