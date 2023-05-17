//
//  TuningView.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/15/23.
//

import Foundation
import SwiftUI
import SandKit
import Granite

struct TuningView: View {
    @GraniteAction<PromptConfig> var setConfig
    
    @Relay var config: ConfigService
    
    var isPopup: Bool = false
    var updateCustomConfigDirectly: Bool = false
    
    @State var useCustomSettings: Bool = true
    @State var promptTemperature: Double = 0.5
    @State var promptTopP: Double = 0.5
    @State var promptNumberOfAnswers: Int = 1
    @State var promptMaxTokens: Int = 4096
    @State var promptMaxTokensDisplay: String = "4096"
    @State var promptEngine: String = "gpt-3.5-turbo"
    @State var useTopP: Bool = false
    
    var promptConfig: PromptConfig {
        .init(temperature: promptTemperature,
              topP: useTopP ? promptTopP : nil,
              numberOfAnswers: Double(promptNumberOfAnswers),
              maximumTokens: promptMaxTokens,
              engine: promptEngine)
    }
    
    init(isPopup: Bool = false,
         updateCustomConfigDirectly: Bool = false,
         config: PromptConfig) {
        self.isPopup = isPopup
        self.updateCustomConfigDirectly = updateCustomConfigDirectly
        
        self.promptTemperature = config.temperature ?? self.promptTemperature
        self.promptTopP = config.topP ?? self.promptTopP
        self.useTopP = config.topP != nil
        self.promptNumberOfAnswers = Int(config.numberOfAnswers ?? Double(self.promptNumberOfAnswers))
        self.promptMaxTokens = config.maximumTokens ?? self.promptMaxTokens
        self.promptEngine = config.engine
    }
    
    init(isPopup: Bool = false,
         updateCustomConfigDirectly: Bool = false) {
        self.isPopup = isPopup
        self.updateCustomConfigDirectly = updateCustomConfigDirectly
    }
    
    var body: some View {
        customizeAPIView
    }
    
    var customizeAPIView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("Tune")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
            } icon: {
                Image (systemName: "rotate.3d")
            }
            .padding(.bottom, isPopup ? 8 : 0)
            
            if isPopup == false {
                Text("For general queries, custom prompts override these settings.")
                
                HStack {
                    Toggle("Enable custom settings", isOn: $useCustomSettings)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                .onChange(of: useCustomSettings) { newValue in
                    guard updateCustomConfigDirectly else { return }
                    config.center.$state.binding.customPromptConfigEnabled.wrappedValue = newValue
                }
            }
            
            if useCustomSettings {
                customSettingsView
                    .onChange(of: promptConfig) { newValue in
                        guard updateCustomConfigDirectly else { return }
                        config.center.$state.binding.customPromptConfig.wrappedValue = newValue
                    }
            }
            
            if isPopup {
                AppBlurView(tintColor: Brand.Colors.purple.opacity(0.3)) {
                    
                    Button(action: {
                        setConfig.perform(promptConfig)
                    }) {
                        Text("Save")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }.buttonStyle(PlainButtonStyle())
                }
                .environment(\.colorScheme, .dark)
                .padding(.top, 8)
            }
        }
        .padding(isPopup ? 16 : 0)
    }
    
    var customSettingsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Temperature")
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                    HStack(spacing: 8) {
                        AppBlurView(size: .init(30, 30)) {
                            Text(String(format: "%.2f", promptTemperature))
                                .font(Fonts.live(.footnote, .bold))
                                .foregroundColor(.foreground)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, isPopup ? 16 : 0)
                        
                        CustomSliderView(value: $promptTemperature,
                                         color: Brand.Colors.purple.opacity(0.45))
                        .frame(width: 120, height: 20)
                        
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top P")
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                    HStack(spacing: 8) {
                        AppBlurView(size: .init(30, 30)) {
                            Text(String(format: "%.2f", promptTopP))
                                .font(Fonts.live(.footnote, .bold))
                                .foregroundColor(.foreground)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, isPopup ? 16 : 0)
                        
                        CustomSliderView(value: $promptTopP,
                                         color: Brand.Colors.purple.opacity(0.45))
                        .frame(width: 120, height: 20)
                        
                        Spacer()
                    }
                }
            }
            HStack {
                Toggle("Use Top P over Temperature?", isOn: $useTopP)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("# of Answers")
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                    
                    HStack(spacing: 8) {
                        AppBlurView(size: .init(20, 36),
                                    tintColor: Brand.Colors.black.opacity(0.3)) {
                            Text("\(promptNumberOfAnswers)")
                                .font(Fonts.live(.subheadline, .bold))
                                .foregroundColor(.foreground)
                        }
                        .frame(width: 24, height: 36)
                        .padding(.horizontal, 16)
                        
                        Stepper(value: $promptNumberOfAnswers, in: 1...4) {
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Max Tokens in Response")
                        .font(Fonts.live(.subheadline, .bold))
                        .foregroundColor(.foreground)
                    
                    HStack(spacing: 8) {
                        AppBlurView(size: .init(44, 36),
                                    tintColor: Brand.Colors.black.opacity(0.3)) {
                            TextField(.init(""), text: $promptMaxTokensDisplay)
                                .textFieldStyle(PlainTextFieldStyle())
                                .multilineTextAlignment(.center)
                                .font(Fonts.live(.subheadline, .bold))
                                .foregroundColor(.foreground)
                                .padding(.bottom, 2)
                        }
                        .frame(width: 48, height: 36)
                        .padding(.horizontal, 16)
                        .onChange(of: promptMaxTokensDisplay) { newValue in
                            if let intValue = Int(newValue) {
                                if intValue != promptMaxTokens {
                                    promptMaxTokens = max(2048, min(4096, intValue))
                                }
                            } else {
                                promptMaxTokensDisplay = "\(promptMaxTokens)"
                            }
                        }
                        
                        Stepper(value: $promptMaxTokens, in: 2048...4096) {
                            EmptyView()
                        }
                        .onChange(of: promptMaxTokens) { newValue in
                            promptMaxTokensDisplay = "\(newValue)"
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Engine")
                    .font(Fonts.live(.subheadline, .bold))
                    .foregroundColor(.foreground)
                
                HStack(spacing: 8) {
                    AppBlurView(size: .init(100, 36),
                                tintColor: Brand.Colors.black.opacity(0.3)) {
                        TextField(.init(""), text: $promptEngine)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.center)
                            .font(Fonts.live(.subheadline, .bold))
                            .foregroundColor(.foreground)
                            .padding(.bottom, 2)
                    }
                    .frame(width: 104, height: 36)
                    .padding(.horizontal, 16)
                }
            }
            .onChange(of: promptEngine) { newValue in
                let sanitized = newValue.newlinesSanitized
                if newValue.utf8.count != sanitized.utf8.count {
                    promptEngine = sanitized
                }
            }
        }
    }
}
