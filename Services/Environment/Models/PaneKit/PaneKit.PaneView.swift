//
//  WindowManager.VisualEffectView.swift
//  Sina
//
//  Created by Ritesh Pakala on 5/7/23.
//

import Foundation
import SwiftUI
import Combine

struct PaneView: View {

    var body: some View {
        ZStack {
            VisualEffectBackground()
                .ignoresSafeArea()
                .zIndex(0)
                
            Mount()
                .ignoresSafeArea()
                .zIndex(2)
        }
        .frame(width: WindowComponent.Style.defaultWindowSize.width)
        .frame(minHeight: WindowComponent.Style.defaultWindowSize.height)
        //.preferredColorScheme(.light)
    }
}


