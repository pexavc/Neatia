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
    @Relay var service: PromptService
    
    @GraniteAction<Void> var createPrompt
    @GraniteAction<CustomPrompt> var editPrompt
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Collection")
                        .font(Fonts.live(.title2, .bold))
                        .foregroundColor(.foreground)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                ScrollView([.vertical]) {
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 126))],
                              alignment: .leading,
                              spacing: 4) {
                        addView
                        
                        ForEach(service.state.customPrompts) { prompt in
        
                            Button {
                                editPrompt.perform(prompt)
                            } label: {
                                promptPreview(prompt)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 126, height: 126)
                            
        
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.top, WindowComponent.Style.defaultComponentOuterPaddingContainerAware)
        }.padding(16)
    }
    
    func promptPreview(_ prompt: CustomPrompt) -> some View {
        AppBlurView(size: .init(0, 126)) {
            
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        IconView(systemName: prompt.iconName,
                                 bgColor: prompt.baseColor,
                                 withBlur: true)
                        
                        Text("/\(prompt.command.command)")
                            .font(Fonts.live(.defaultSize, .bold))
                        
                        Spacer()
                    }
                    
                    Text("\(prompt.description)")
                        .lineLimit(nil)
                        .font(Fonts.live(.subheadline, .regular))
                    
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
