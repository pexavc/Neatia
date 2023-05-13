import Granite

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
}
