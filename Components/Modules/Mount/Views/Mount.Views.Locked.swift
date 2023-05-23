//
//  Mount.Views.Locked.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/13/23.
//

import Granite
import GraniteUI
import SwiftUI

extension Mount {
    
    var lockedView: some View {
        HStack {
            Spacer()
            if session.isLifetimeAPI && session.isLocked {
                AppBlurView(tintColor: Brand.Colors.purple.opacity(0.3)) {
                    Button {
                        config.center.$state.binding.isSettingsActive.wrappedValue = true
                        MenuBarManager.shared.showPopOver()
                    } label : {
                        Text("Set API Key")
                            .font(Fonts.live(.headline, .bold))
                            .foregroundColor(.foreground)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .environment(\.colorScheme, .dark)
            } else if session.isLocked {
                if session.isSubscribed == false || session.isLoggedIn == false {
                    AppBlurView(tintColor: Brand.Colors.purple.opacity(0.3)) {
                        
                        Button {
                            config.center.$state.binding.isAccountTabActive.wrappedValue = true
                            MenuBarManager.shared.showPopOver()
                        } label : {
                            Text(session.isLoggedIn ? "Subscribe" : "Log In")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                }
                
                if session.isLoggedIn {
                    if session.isSubscribed == false {
                        Text("or")
                    }
                    
                    AppBlurView(tintColor: Brand.Colors.purple.opacity(0.3)) {
                        Button {
                            config.center.$state.binding.isSettingsActive.wrappedValue = true
                            MenuBarManager.shared.showPopOver()
                        } label : {
                            Text("Purchase Lifetime API Access")
                                .font(Fonts.live(.headline, .bold))
                                .foregroundColor(.foreground)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .environment(\.colorScheme, .dark)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, WindowComponent.Style.defaultTitleBarHeight)
        .background(Brand.Colors.black.opacity(0.5))
    }
}
