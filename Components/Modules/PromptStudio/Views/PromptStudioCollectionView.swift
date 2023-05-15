//
//  PromptStudioCollectionView.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/13/23.
//

import Foundation
import Granite
import SwiftUI

struct PromptStudioCollectionView: View {
    var preview: Bool = false
    
    @SharedObject("nyc.stoic.Neatia.WindowVisibilityManager") var windowVisibility: WindowVisibilityManager
    
    @Relay var service: PromptService
    
    @GraniteAction<Void> var createPrompt
    @GraniteAction<CustomPrompt> var editPrompt
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                if preview == false {
                    HStack {
                        Text("Collection")
                            .font(Fonts.live(.title2, .bold))
                            .foregroundColor(.foreground)
                        
                        Spacer()
                    }
                    .padding(.bottom, 8)
                }
                
                ScrollView([.vertical]) {
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 126))],
                              alignment: .leading,
                              spacing: 4) {
                        
                        if preview == false {
                            addView
                        }
                        
                        if service.state.customPrompts.isEmpty && preview {
                            AppBlurView(size: .init(0, 80),
                                        tintColor: Brand.Colors.black.opacity(0.3)) {
                                HStack {
                                    Text("Open the studio to create custom prompts with commands to personalize experience.")
                                        .font(Fonts.live(.defaultSize, .bold))
                                    
                                    Spacer()
                                    
                                }
                            }
                            .frame(width: 360, height: 80)
                        } else {
                            
                            ForEach(service.state.customPrompts) { prompt in
                                
                                Button {
                                    if preview {
                                        guard windowVisibility.isVisible(id: InteractionManager.Kind.promptStudio.rawValue) == false else { return }
                                        
                                        let nc = NotificationCenter.default
                                        nc.post(name: Notification.Name("nyc.stoic.Neatia.ShowHidePromptStudio"), object: nil)
                                    } else {
                                        editPrompt.perform(prompt)
                                    }
                                } label: {
                                    promptPreview(prompt)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(width: 126, height: 126)
                                
                                
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.top, WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
        }.padding(preview ? 0 : 16)
    }
    
    func promptPreview(_ prompt: CustomPrompt) -> some View {
        AppBlurView(size: .init(0, 126),
                    tintColor: prompt.baseColor.opacity(0.45)) {
            
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        AppBlurView(size: .init(24, 24),
                                    padding: .init(.zero),
                                    tintColor: Brand.Colors.black.opacity(0.3)) {
                            Image(systemName: prompt.iconName)
                                .font(Fonts.live(.caption2, .bold))
                                .foregroundColor(.foreground)
                                .environment(\.colorScheme, .dark)
                                .padding(.bottom, 2)
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 24, height: 24)
                        
                        Text("/\(prompt.command.command)")
                            .font(Fonts.live(.caption2, .bold))
                        
                        Spacer()
                    }
                    
                    Text("\(prompt.description)")
                        .lineLimit(nil)
                        .font(Fonts.live(.caption, .regular))
                    
                    Spacer()
                    
                    HStack {
                        Text("\(prompt.dateCreated.asString)")
                            .font(Fonts.live(.caption2, .bold))
                        
                        Spacer()
                    }
                }
                .padding(8)
            }.frame(width: 126, height: 126)
        }
        .frame(width: 126, height: 126)
    }
    
    var addView: some View {
        Button {
            createPrompt.perform()
        } label: {
            AppBlurView(size: .init(0, 126)) {
                Image(systemName: "plus")
                    .font(Fonts.live(.largeTitle, .bold))
                    .frame(width: 126, height: 126)
            }
            .frame(width: 126, height: 126)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 126, height: 126)
    }
}
