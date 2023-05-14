//
//  PromptStudioEditorView.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/13/23.
//

import Foundation
import Granite
import SwiftUI

struct PromptStudioEditorView: View {
    @GraniteAction<Void> var closeCreatePrompt
    
    @Relay var service: PromptService
    
    var isEditing: Bool = false
    
    var titleText: String {
        if isEditing {
            return "Edit prompt"
        } else {
            return "Create new prompt"
        }
    }
    
    @State var promptCommand: String
    @State var promptBody: String
    @State var promptDescription: String
    @State var promptColor: String = ColorPicker.toHex(h: 0.5, s: 0.5, b: 0.5)
    @State var promptIcon: String
    @State var showError: Bool = false
    
    var asCustomPrompt: CustomPrompt {
        .init(.init(promptCommand),
              prompt: promptBody,
              iconName: promptIcon,
              baseColorHex: promptColor,
              description: promptDescription)
    }
    
    init() {
        promptCommand = ""
        promptBody = ""
        promptDescription = ""
        promptColor = ColorPicker.toHex(h: 0.5, s: 0.5, b: 0.5)
        promptIcon = "questionmark"
    }
    
    init(_ prompt: CustomPrompt) {
        self.isEditing = true
        
        promptCommand = prompt.command.command
        promptBody = prompt.prompt
        promptDescription = prompt.description
        promptColor = prompt.baseColorHex
        promptIcon = prompt.iconName
    }
    
    var promptTokenCount: Int {
        SandGPT.shared.gpt3Tokenizer.encoder.enconde(text: promptBody).count
    }
    
    var isValid: Bool {
        promptCommand.isNotEmpty &&
        promptBody.isNotEmpty &&
        promptDescription.isNotEmpty &&
        promptTokenCount <= PromptService.maxTokenCount
    }
    
    var errorMessage: String {
        if promptTokenCount <= PromptService.maxTokenCount {
            return "Reduce the token count of your instructions to \(PromptService.maxTokenCount) tokens or less."
        }
        
        var string: String = "You still need to add "
        
        var issues: [String] = []
        if promptCommand.isEmpty {
            issues.append("a command")
        }
        
        if promptDescription.isEmpty {
            issues.append("a description")
        }
        
        if promptBody.isEmpty {
            if issues.count > 0 {
                issues.append("and instructions")
            } else {
                issues.append("instructions")
            }
        } else if issues.count > 1 {
            issues.insert("and", at: issues.count - 1)
        }
        
        string += issues.joined(separator: issues.count > 2 ? ", " : " ")
        
        return string
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(titleText)
                        .font(Fonts.live(.title2, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                    
                    AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                        Button(action: {
                            closeCreatePrompt.perform()
                        }) {
                            Text("Back")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                    .padding(.top, 4)
                }
                .padding(.bottom, 8)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text("Command")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                        
                        AppBlurView(size: .init(120, 60)) {
                            MacEditorTextView(
                                text: $promptCommand,
                                isEditable: true,
                                font: Fonts.nsFont(.defaultSize, .bold))
                        }
                        .frame(width: 120, height: 60)
                        .padding(.horizontal, 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                        
                        PopupableView(.promptStudio,
                                      size: .init(200, 200),
                                      edge: .maxX, {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color(hex: promptColor))
                        }) {
                            ColorPicker(hex: $promptColor)
                        }
                        .frame(width: 60, height: 60)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Icon")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                        
                        PopupableView(.promptStudio,
                                      size: .init(200, 300),
                                      edge: .maxX, {
                            
                            AppBlurView(size: .init(0, 60)) {
                                Image(systemName: promptIcon)
                                    .font(Fonts.live(.title, .bold))
                            }
                            .frame(width: 60, height: 60)
                        }) {
                            SFSymbolsPicker(icon: $promptIcon)
                        }
                        .frame(width: 60, height: 60)
                    }
                    
                    
                    Spacer()
                }
                .padding(.bottom, 4)
                
                Text("Short Description")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                AppBlurView(size: .init(0, 60)) {
                    MacEditorTextView(
                        text: $promptDescription,
                        isEditable: true,
                        font: Fonts.nsFont(.defaultSize, .bold))
                }
                .frame(height: 60)
                .padding(.bottom, 4)
                
                Text("Instructions")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
                
                ZStack {
                    AppBlurView(size: .init(0, 240)) {
                        MacEditorTextView(
                            text: $promptBody,
                            isEditable: true,
                            font: Fonts.nsFont(.defaultSize, .bold))
                    }
                    .frame(height: 240)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Text("\(promptTokenCount)/\(PromptService.maxTokenCount)")
                                .font(Fonts.live(.caption, .bold))
                                .foregroundColor((promptTokenCount <= PromptService.maxTokenCount ? Brand.Colors.green : Brand.Colors.red).opacity(0.55))
                            
                        }
                        
                        Spacer()
                            .frame(height: WindowComponent.Style.defaultContainerOuterPadding)
                    }
                    .padding(8)
                    .allowsHitTesting(false)
                }
                .frame(height: 240)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Spacer()
                    
                    if isEditing {
                        AppBlurView(tintColor: Brand.Colors.red.opacity(0.3)) {
                            Button(action: {
                                service
                                    .center
                                    .delete
                                    .send(PromptService
                                        .Delete
                                        .Meta(prompt: asCustomPrompt))
                                
                                closeCreatePrompt.perform()
                            }) {
                                Text("Delete")
                                    .font(Fonts.live(.headline, .bold))
                                    .foregroundColor(.foreground)
                            }.buttonStyle(PlainButtonStyle())
                        }
                        .environment(\.colorScheme, .dark)
                    }
                    
                    AppBlurView(tintColor: Brand.Colors.purple.opacity(0.45)) {
                        Button(action: {
                            if isValid {
                                if isEditing {
                                    
                                    service
                                        .center
                                        .modify
                                        .send(PromptService
                                            .Modify
                                            .Meta(prompt: asCustomPrompt))
                                } else {
                                    
                                    service
                                        .center
                                        .create
                                        .send(PromptService
                                            .Create
                                            .Meta(prompt: asCustomPrompt))
                                }
                                
                                closeCreatePrompt.perform()
                            } else {
                                showError = true
                            }
                        }) {
                            Text(isEditing ? "Update" : "Create")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Spacer()
            }
            .padding(.vertical, WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
//            VStack(spacing: 8) {
//                MacEditorTextView(
//                    text: $promptBody,
//                    isEditable: true,
//                    font: Fonts.nsFont(.defaultSize, .bold))
//            }
//            .padding(WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
        }
        .padding(16)
        .alert(errorMessage, isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
    }
    
    var background: some View {
        VStack(spacing: 0) {
            VisualEffectBackground(overlayColor: Color.background)
                .cornerRadius(8)
        }
        .padding(WindowComponent.Style.defaultContainerOuterPadding)
    }
}
