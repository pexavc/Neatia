import Granite
import SandKit
import Foundation
import Markdown
import SwiftUI

extension SandService {
    struct Restore: GraniteReducer {
        typealias Center = SandService.Center
        
        struct Meta: GranitePayload {
            let history: QueryHistory
        }
        
        @Payload var meta: Meta?
        
        @Relay var query: QueryService
        
        @Event var setAskResponse: AskResponse.Reducer
        @Event var setCommand: SetCommand.Reducer
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            
            query.center.restore.send(QueryService.Restore.Meta(value: meta.history.query))
            
            setAskResponse.send(SandGPT.Response(data: meta.history.response,
                                                 isComplete: true,
                                                 isStream: false,
                                                 isRestoring: true))
            
            if let command = meta.history.command {
                setCommand.send(SetCommand.Meta(value: command, reset: false))
//                state.subCommandSet = meta.history.subCommandSet
//                state.subCommandFileSet = meta.history.subCommandFileSet
            }
        }
    }
}
