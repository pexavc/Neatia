//
//  Special+State.swift
//  Stoic
//
//  Created by PEXAVC on 12/20/22.
//

import Foundation
import Granite

extension Special {
    struct Center: GraniteCenter {
        struct State: GraniteState {
            static func == (lhs: Special.Center.State, rhs: Special.Center.State) -> Bool {
                true
            }
            
            enum CodingKeys: CodingKey {}
            var scene: SceneKitView = SceneKitView()
        }
        
        @Store var state: State
    }
}
