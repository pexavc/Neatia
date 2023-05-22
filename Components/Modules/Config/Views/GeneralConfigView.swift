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
    
    @State var apiKey: String = ""
    
    var isLifetimeAPIPurchased: Bool {
        VaultManager.purchased(VaultProducts.Lifetime.basic) || VaultManager.isSubscribed
    }
    
    var product: VaultProduct? {
        VaultManager.shared.productFor(VaultProducts.Lifetime.basic)
    }
    
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
            
            HStack {
                Toggle("Stream Response", isOn: config.center.$state.binding.streamResponse)
                
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
                    if isLifetimeAPIPurchased {
                        MacEditorTextView(
                            text: $apiKey,
                            isEditable: true,
                            font: Fonts.nsFont(.defaultSize, .bold))
                    } else {
                        MacEditorTextView(
                            text: $apiKey,
                            isEditable: false,
                            font: Fonts.nsFont(.defaultSize, .bold))
                    }
                }
                .frame(height: 60)
                
                if isLifetimeAPIPurchased {
                    
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
                } else {
                    
                    AppBlurView(tintColor: Brand.Colors.yellow.opacity(0.3)) {
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                account
                                    .center
                                    .purchase
                                    .send(AccountService.Purchase.Meta(product: product))
                            }) {
                                Text("Purchase Lifetime API Access")
                                    .font(Fonts.live(.headline, .bold))
                                    .foregroundColor(.foreground)
                                
                                if let vaultProduct = product {
                                    Divider()
                                    
                                    Text(vaultProduct.metadata.displayPrice)
                                        .font(Fonts.live(.subheadline, .bold))
                                        .foregroundColor(.foreground)
                                }
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                    .environment(\.colorScheme, .dark)
                    .padding(.bottom, 8)
                }
                
                Text("More options appear after a key is set, helping you customize your experience.")
                
                Text("Get your own OpenAI API Key here.")
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        if let url = URL(string: "https://platform.openai.com/account/api-keys") {
                            openURL(url)
                        }
                    }
                
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
