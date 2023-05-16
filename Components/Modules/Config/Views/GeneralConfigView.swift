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
    
    @State var apiKey: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Settings")
                    .font(Fonts.live(.title2, .bold))
                    .foregroundColor(.foreground)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            Text("Behavior")
                .font(Fonts.live(.headline, .bold))
                .foregroundColor(.foreground)
            
            HStack {
                Toggle("Start on launch", isOn: config.center.$state.binding.launchAtLogin)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
//            Text("Accessibility")
//                .font(Fonts.live(.headline, .bold))
//                .foregroundColor(.foreground)
//
//            HStack {
//                Toggle("Visual guide", isOn: config.center.$state.binding.showVisualGuide)
//
//                Spacer()
//            }
//            .padding(.bottom, 8)
            
            if config.state.isCustomAPIKeySet {
                
                TuningView(updateCustomConfigDirectly: true)
                
            } else {
                Text("Custom API Key for OpenAI's ChatGPT")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                AppBlurView(size: .init(0, 60),
                            tintColor: Brand.Colors.black.opacity(0.3)) {
                    MacEditorTextView(
                        text: $apiKey,
                        isEditable: true,
                        font: Fonts.nsFont(.defaultSize, .bold))
                }
                .frame(height: 60)
                
                AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                    
                    Button(action: {
                        config
                            .center
                            .setAPIKey
                            .send(ConfigService.SetCustomAPIKey.Meta(key: apiKey))
                    }) {
                        Text("Set API Key")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }.buttonStyle(PlainButtonStyle())
                }
                .environment(\.colorScheme, .dark)
                .padding(.bottom, 8)
                
                Text("More options appear after a key is set, to help you customize your experience.")
            }
            
            
            Spacer()
            
            if config.state.isCustomAPIKeySet {
                AppBlurView(tintColor: Brand.Colors.red.opacity(0.3)) {
                    
                    Button(action: {
                        config
                            .center
                            .removeAPIKey
                            .send()
                    }) {
                        Text("Delete API Key")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }.buttonStyle(PlainButtonStyle())
                }
                .environment(\.colorScheme, .dark)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
    
    
}
