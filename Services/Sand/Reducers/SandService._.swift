//
//  SandService._.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/14/23.
//

import Granite
import SandKit
import Foundation
import PDFKit

extension SandService {
    struct Reset: GraniteReducer {
        typealias Center = SandService.Center
        
        func reduce(state: inout Center.State) {
            
            state.query = ""
            state.response = ""
            state.isResponding = false
            state.commandAutoComplete = []
            state.subCommandSet = nil
            state.subCommandFileSet = nil
            state.commandSet = nil
            SandGPTTokenizerManager.shared.pause = false
        }
    }
}
