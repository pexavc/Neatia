//
//  EnvironmentService.Hotkey.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/6/23.
//

import Foundation
import Granite

extension EnvironmentService {
    struct HotkeyDetected: GraniteReducer {
        typealias Center = EnvironmentService.Center
        
        func reduce(state: inout Center.State) {
            state.pane?.toggleWindow()
            //state.windowManager.toggle(.mount)
        }
    }
}
