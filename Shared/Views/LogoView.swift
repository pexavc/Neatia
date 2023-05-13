//
//  LogoView.swift
//  Neatia
//
//  Created by Ritesh Pakala on 5/12/23.
//

import SwiftUI

struct LogoView: View {
    @State private var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 24.0)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
            .animation(foreverAnimation, value: isAnimating)
            .onAppear { self.isAnimating = true }
    }
}
