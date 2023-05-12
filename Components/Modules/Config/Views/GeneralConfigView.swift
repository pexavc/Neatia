//
//  GeneralConfigView.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/5/23.
//

import Foundation
import SwiftUI
import Granite
import ServiceManagement

struct GeneralConfigView: View {
    @Relay var config: ConfigService
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Visual guide", isOn: config.center.$state.binding.showVisualGuide)
            Toggle("Start on launch", isOn: config.center.$state.binding.launchAtLogin)
        }
        .padding(8)
    }
}
