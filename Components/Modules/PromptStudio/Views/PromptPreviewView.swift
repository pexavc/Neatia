//
//  PromptPreview.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/18/23.
//

import Foundation
import SwiftUI
import Granite
import SandKit

struct PromptPreviewView: View {
    enum Size {
        case normal
        case large
    }
    var prompt: BasicPrompt
    var size: CGSize = .init(126, 126)
    var styleSize: Size = .normal
    
    var iconSize: CGFloat {
        switch styleSize {
        case .large:
            return 36
        case .normal:
            return 24
        }
    }
    
    @State var isHovering: Bool = false
    
    var body: some View {
        AppBlurView(size: .init(0, size.height),
                    tintColor: prompt.baseColor.opacity(0.45)) {
            
            ZStack {
                if prompt.isSystemPrompt {
                    Image("logo_granite")
                        .resizable()
                        .opacity(0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                if isHovering {
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundColor(.accentColor.opacity(0.9))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        AppBlurView(size: .init(iconSize, iconSize),
                                    padding: .init(.zero),
                                    tintColor: Brand.Colors.black.opacity(0.3)) {
                            Image(systemName: prompt.iconName)
                                .font(Fonts.live(styleSize == .large ? .subheadline : .caption2, .bold))
                                .foregroundColor(.foreground)
                                .environment(\.colorScheme, .dark)
                                .padding(.bottom, 2)
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        
                        Text("/\(prompt.command.value)")
                            .font(Fonts.live(styleSize == .large ? .subheadline : .caption2, .bold))
                        
                        Spacer()
                    }
                    
                    Text("\(prompt.description)")
                        .lineLimit(nil)
                        .font(Fonts.live(styleSize == .large ? .footnote : .caption, .regular))
                    
                    Spacer()
                    
                    HStack {
                        Text("Tokens: \(prompt.promptTokenCount)")
                            .font(Fonts.live(.caption2, .bold))
                        
                        Spacer()
                    }
                    
                    if let date = prompt.dateCreated {
                        HStack {
                            Text("\(date.asString)")
                                .font(Fonts.live(.caption2, .bold))
                            
                            Spacer()
                        }
                    }
                }
                .padding(8)
            }.frame(width: size.width, height: size.height)
        }
        .frame(width: size.width, height: size.height)
        .onHover { isHovered in
            DispatchQueue.main.async { //<-- Here
                self.isHovering = isHovered
                if self.isHovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}
