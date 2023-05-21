//
//  ConfigService.History.swift
//  Neatia (iOS)
//
//  Created by Ritesh Pakala on 5/20/23.
//

import Granite
import SwiftUI
import Foundation
import SandKit

extension ConfigService {
    struct UpdateHistory: GraniteReducer {
        typealias Center = ConfigService.Center
        
        struct Meta: GranitePayload {
            let query: String
            let response: String
            let prompt: (any BasicPrompt)?
            var subCommandSet: [String: Prompts.Subcommand]?
            var subCommandFileSet: [String: [String: String]]?
        }
        
        @Payload var meta: Meta?
        
        func reduce(state: inout Center.State) {
            guard let meta = self.meta else { return }
            var history = state.history
            //TODO: subcommandSet should be via id not the whole object
            //too keep prompts private
            history.append(.init(query: meta.query,
                                 response: meta.response,
                                 command: meta.prompt?.command.value,
                                 subCommandSet: nil,//meta.subCommandSet,
                                 subCommandFileSet: meta.subCommandFileSet,
                                 iconName: meta.prompt?.iconName,
                                 baseColor: meta.prompt?.baseColor.hexaRGB,
                                 isSystemPrompt: meta.prompt?.isSystemPrompt == true))
            
            state.history = history.suffix(8)
        }
    }
}
