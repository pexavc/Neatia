//
//  GraniteDisclaimerView.swift
//  Stoic
//
//  Created by PEXAVC on 1/3/23.
//

import Foundation
import SwiftUI

public struct GraniteDisclaimerView: View {
    var opacity: Double = 1.0
    var hasLeftButton: Bool = false
    var leftButtonText: LocalizedStringKey = "Cancel"
    var rightButtonText: LocalizedStringKey = "Done"
    
    var text: LocalizedStringKey
    var gradientColors: [Color]
    var isLoader: Bool
    var isActionable: Bool
    
    init(_ text: LocalizedStringKey = "",
         gradientColors: [Color] = [Brand.Colors.marbleV2, Brand.Colors.marble],
         isActionable: Bool = false,
         isLoader: Bool = false) {
        
        self.text = text
        self.gradientColors = gradientColors
        self.isActionable = isActionable
        self.isLoader = isLoader
        
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            GradientView(colors: gradientColors,
                         direction: .topLeading)
            .opacity(opacity).overlay (
                
                VStack(spacing: 0) {
                    if isLoader {
                        
                        ProgressView().scaleEffect(0.84)
                            .frame(width: 48, height: 48)
                            .background(Brand.Colors.black
                                .opacity(0.57)
                                .cornerRadius(8.0)
                                .shadow(color: Color.black.opacity(0.57), radius: 4, x: 1, y: 2)
                                .padding(.top, Brand.Padding.medium)
                                .padding(.bottom, Brand.Padding.medium)
                                .padding(.leading, Brand.Padding.medium)
                                .padding(.trailing, Brand.Padding.medium))
                        
                    } else {
                        
                        GraniteText(text,
                                    .subheadline,
                                    .bold,
                                    padding: Brand.Padding.medium)
                            .padding(.top, Brand.Padding.medium)
                            .padding(.bottom, Brand.Padding.medium)
                            .padding(.leading, Brand.Padding.large)
                            .padding(.trailing, Brand.Padding.large)
                            .background(Brand.Colors.black
                                .opacity(0.57)
                                .cornerRadius(8.0)
                                .shadow(color: Color.black.opacity(0.57), radius: 4, x: 1, y: 2)
                                .padding(.top, Brand.Padding.medium)
                                .padding(.bottom, Brand.Padding.medium)
                                .padding(.leading, Brand.Padding.medium)
                                .padding(.trailing, Brand.Padding.medium))
                        
                        if hasLeftButton {
                            HStack {
                                if hasLeftButton {
                                    
                                    GraniteButton(leftButtonText,
                                                  textColor: Brand.Colors.greyV2,
                                                  colors: [Brand.Colors.black,
                                                           Brand.Colors.black.opacity(0.24)])
                                }
                                
                                GraniteButton(rightButtonText,
                                              textColor: Brand.Colors.greyV2,
                                              colors: [Brand.Colors.black,
                                                       Brand.Colors.black.opacity(0.24)])
                            }
                        }
                    }
                }
                
                
            )
            .shadow(color: Color.black, radius: 6.0, x: 4.0, y: 3.0)
            
            
            
            Spacer()
        }
        .padding(.horizontal, Brand.Padding.medium)
    }
}
