import Granite

extension ConfigService {
    struct Hotkey: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            let key: InteractionManager.HotkeyOptions
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            state.mountHotkey = meta.key
            InteractionManager.shared.registerHotkey(meta.key)
        }
    }
}
