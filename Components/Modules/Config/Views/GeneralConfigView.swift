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
import VaultKit

struct GeneralConfigView: View {
    @Environment(\.openURL) var openURL
    
    @Relay var config: ConfigService
    @Relay var account: AccountService
    
    @SharedObject(SessionManager.id) var session: SessionManager
    
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
            
            if config.state.isAzure != true {
                HStack {
                    Toggle("Stream response", isOn: config.center.$state.binding.streamResponse)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
            }
            
            Text("Engine Class")
                .font(Fonts.live(.headline, .bold))
                .foregroundColor(.foreground)
            
            HStack {
                Toggle("Azure OpenAI", isOn: config.center.$state.binding.isAzure)
                
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
            
            if config.state.isCustomAPIKeySet || session.isSubscribed {
                TuningView(updateCustomConfigDirectly: true,
                           config: config.state.customPromptConfig)
                
            } else if SessionManager.IS_API_ACCESS_ENABLED {
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
                
                if SessionManager.IS_API_ACCESS_ENABLED {
                    
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
                }
                
                if SessionManager.IS_API_ACCESS_ENABLED {
                    Text("More options appear after a key is set, helping you customize your experience.")
                        .foregroundColor(.foreground)
                    
                    Text("Get your own OpenAI API Key here.")
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            if let url = URL(string: "https://platform.openai.com/account/api-keys") {
                                openURL(url)
                            }
                        }
                }
                
            } else {
                Text("More options appear after subscribing, helping you customize your general experience.")
                    .foregroundColor(.foreground)
                
                AppBlurView(tintColor: Brand.Colors.yellow.opacity(0.3)) {
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            config.center.$state.binding.isAccountTabActive.wrappedValue = true
                        }) {
                            Text("Subscribe")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .environment(\.colorScheme, .dark)
                .padding(.bottom, 8)
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
