//
//  GeneralConfigView.swift
//  Neatia
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Settings")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            HStack {
                Toggle("Visual guide", isOn: config.center.$state.binding.showVisualGuide)
                
                Spacer()
            }
            
            HStack {
                Toggle("Start on launch", isOn: config.center.$state.binding.launchAtLogin)
                
                Spacer()
            }
            
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
}
