//
//  TextViews.swift
//  * stoic (iOS)
//
//  Created by PEXAVC on 1/6/21.
//

import Foundation
import SwiftUI

public struct GraniteText: View {
    let text: LocalizedStringKey
    let font: Font
    let color: Color
    let alignment: TextAlignment
    let verticalAlignment: VerticalAlignment
    let style: TextShadowSettings
    let selected: Bool
    let addSpacers: Bool
    let padding: CGFloat
    
    public struct TextShadowSettings {
        let radius: CGFloat
        let offset: CGPoint
        let selectionColor: Color
        let selectionStyle: SelectionStyle
        let gradient: [Color]
        
        var gradientEnabled: Bool {
            gradient.isNotEmpty
        }
        
        public enum SelectionStyle {
            case v1
            case v2
        }
        
        public init(radius: CGFloat,
                    offset: CGPoint,
                    selectionColor: Color = Brand.Colors.black,
                    selectionStyle: SelectionStyle = .v1,
                    gradient: [Color] = []) {
            self.radius = radius
            self.offset = offset
            self.selectionColor = selectionColor
            self.selectionStyle = selectionStyle
            self.gradient = gradient
        }
        
        public init(selectionColor: Color = Brand.Colors.black,
                    selectionStyle: SelectionStyle = .v1,
                    gradient: [Color] = []) {
            self.radius = TextShadowSettings.basic.radius
            self.offset = TextShadowSettings.basic.offset
            self.selectionColor = selectionColor
            self.selectionStyle = selectionStyle
            self.gradient = gradient
        }
        
        public static var basic: TextShadowSettings {
            .init(radius: 3, offset: .init(x: 2, y: 2))
        }
        
        public static var v2Selection: TextShadowSettings {
            .init(radius: 3, offset: .init(x: 2, y: 2), selectionStyle: .v2)
        }
    }
    
    public init(_ text: LocalizedStringKey,
                _ color: Color = Brand.Colors.white,
                _ size: Fonts.FontSize = .subheadline,
                _ weight: Fonts.FontWeight = .regular,
                _ alignment: TextAlignment = .center,
                verticalAlignment: VerticalAlignment = .center,
                style: TextShadowSettings = .basic,
                selected: Bool = false,
                addSpacers: Bool = true,
                padding: CGFloat = 0) {
        self.text = text
        self.font = Fonts.live(size, weight)
        self.color = color
        self.alignment = alignment
        self.style = style
        self.selected = selected
        self.verticalAlignment = verticalAlignment
        self.addSpacers = addSpacers
        self.padding = padding
    }
    
    public init(_ text: LocalizedStringKey,
                _ size: Fonts.FontSize = .subheadline,
                _ weight: Fonts.FontWeight = .regular,
                _ alignment: TextAlignment = .center,
                verticalAlignment: VerticalAlignment = .center,
                style: TextShadowSettings = .basic,
                selected: Bool = false,
                addSpacers: Bool = true,
                padding: CGFloat = 0) {
        self.text = text
        self.font = Fonts.live(size, weight)
        self.color = Brand.Colors.white
        self.alignment = alignment
        self.style = style
        self.selected = selected
        self.verticalAlignment = verticalAlignment
        self.addSpacers = addSpacers
        self.padding = padding
    }
    
    public init(_ text: LocalizedStringKey,
                _ alignment: TextAlignment = .center,
                verticalAlignment: VerticalAlignment = .center,
                style: TextShadowSettings = .basic,
                selected: Bool = false,
                addSpacers: Bool = true,
                padding: CGFloat = 0) {
        self.text = text
        self.font = Fonts.live(.subheadline, .regular)
        self.color = Brand.Colors.white
        self.alignment = alignment
        self.style = style
        self.selected = selected
        self.verticalAlignment = verticalAlignment
        self.addSpacers = addSpacers
        self.padding = padding
    }
    
    public var body: some View {
        HStack(alignment: verticalAlignment, spacing: 0.0) {
            if alignment == .trailing && addSpacers {
                Spacer()
            }
            
            Text(text)
                .foregroundColor(color)
                .font(font)
                .multilineTextAlignment(alignment)
                .lineSpacing(Brand.Padding.xSmall)
                .padding(self.padding)
                .background(
                    Passthrough {
                        if self.selected {
                            switch style.selectionStyle {
                            case .v1:
                                style.selectionColor
                                    .cornerRadius(4)
                                    .padding(.top, -6)
                                    .padding(.leading, -6)
                                    .padding(.trailing, -6)
                                    .padding(.bottom, -6)
                            case .v2:
                                GradientView(colors: [Brand.Colors.marbleV2,
                                                      Brand.Colors.marble],
                                             cornerRadius: 6.0,
                                             direction: .topLeading).overlay (
                                                
                                        Brand.Colors.black
                                                        .opacity(0.57)
                                                        .cornerRadius(4.0)
                                                        .shadow(color: .black, radius: 4, x: 2, y: 2)
                                                        .padding(.top, 6)
                                                        .padding(.leading, 6)
                                                        .padding(.trailing, 6)
                                                        .padding(.bottom, 6)
                                        
                                    
                                    )
                                    .padding(.top, -8)
                                    .padding(.leading, -10)
                                    .padding(.trailing, -10)
                                    .padding(.bottom, -8)
                            }
                        } else if style.gradientEnabled {
                            GradientView(colors: style.gradient,
                                         cornerRadius: 6.0,
                                         direction: .topLeading)
                                .padding(.leading, -Brand.Padding.small)
                                .padding(.trailing, -Brand.Padding.small)
                        }
                    }
                )
            
            //Huge memory leak, with the inner shadow text...
            //
//            if style.disable {
//                Text(text)
//                    .foregroundColor(color)
//                    .font(font)
//                    .multilineTextAlignment(alignment)
//                    .background(
//                        Passthrough {
//                            if self.selected {
//                                style.selectionColor
//                                    .cornerRadius(4)
//                                    .padding(.top, -6)
//                                    .padding(.leading, -6)
//                                    .padding(.trailing, -6)
//                                    .padding(.bottom, -6)
//                            }
//                        }
//                    )
//            } else {
//                Text(text)
//                    .granite_innerShadow(
//                    color,
//                    radius: style.radius,
//                    offset: style.offset)
//                    .font(font)
//                    .multilineTextAlignment(alignment)
//                    .background(
//                        Passthrough {
//                            if self.selected {
//                                style.selectionColor
//                                    .cornerRadius(4)
//                                    .padding(.top, -6)
//                                    .padding(.leading, -6)
//                                    .padding(.trailing, -6)
//                                    .padding(.bottom, -6)
//                            }
//                        }
//                    )
//            }
            
            
            if alignment == .leading && addSpacers {
                Spacer()
            }
        }
    }
}
