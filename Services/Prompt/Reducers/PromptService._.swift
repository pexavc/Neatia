import Granite

extension PromptService {
    struct Create: GraniteReducer {
        typealias Center = PromptService.Center
        
        struct Meta: GranitePayload {
            let prompt: CustomPrompt
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            guard state.customPrompts.filter({ $0.command == meta.prompt.command }).isEmpty else {
                return
            }
            
            state.customPrompts.append(meta.prompt)
        }
    }
    
    struct Modify: GraniteReducer {
        typealias Center = PromptService.Center
        
        struct Meta: GranitePayload {
            let prompt: CustomPrompt
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            guard let index = state.customPrompts.firstIndex(where: { $0.command == meta.prompt.command }) else {
                return
            }
            
            state.customPrompts[index] = meta.prompt
        }
    }
    
    struct Delete: GraniteReducer {
        typealias Center = PromptService.Center
        
        struct Meta: GranitePayload {
            let prompt: CustomPrompt
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            guard let index = state.customPrompts.firstIndex(where: { $0.command == meta.prompt.command }) else {
                return
            }
            
            state.customPrompts.remove(at: index)
        }
    }
}
