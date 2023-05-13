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
            AppBlurView(tintColor: Brand.Colors.black.opacity(0.3)) {
                
                Text(session.isLoggedIn ? "Subscriben" : "Log In")
                    .font(Fonts.live(.headline, .bold))
                    .foregroundColor(.foreground)
            }
            .environment(\.colorScheme, .dark)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, WindowComponent.Style.defaultTitleBarHeight)
    }
}
