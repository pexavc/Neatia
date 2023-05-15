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
            AppBlurView(tintColor: Brand.Colors.purple.opacity(0.3)) {
                
                Text(session.isLoggedIn ? "Subscribe" : "Log In")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
            }
            .environment(\.colorScheme, .dark)
            .onTapGesture {
                config.center.$state.binding.isAccountTabActive.wrappedValue = true
                MenuBarManager.shared.showPopOver()
            }
            
            if session.isLoggedIn && session.isSubscribed == false {
                Text("or")
                
                AppBlurView(tintColor: Brand.Colors.purple.opacity(0.3)) {
                    
                    Text("Set API Key")
                        .font(Fonts.live(.headline, .bold))
                        .foregroundColor(.foreground)
                }
                .environment(\.colorScheme, .dark)
                .onTapGesture {
                    config.center.$state.binding.isSettingsActive.wrappedValue = true
                    MenuBarManager.shared.showPopOver()
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, WindowComponent.Style.defaultTitleBarHeight)
        .background(Brand.Colors.black.opacity(0.5))
    }
}
