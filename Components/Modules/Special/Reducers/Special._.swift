//
//  Special._.swift
//  Stoic
//
//  Created by PEXAVC on 12/20/22.
//

import Granite
import SwiftUI
import Foundation

extension Special {
    struct DidAppear: GraniteReducer {
        typealias Center = Special.Center
        
        func reduce(state: inout Center.State) {
            state.scene.run()
        }
    }
}

