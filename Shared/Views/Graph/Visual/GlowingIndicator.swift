//
//  GlowingIndicator.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

/// Default indicator with glowing effect. Used to show latest value in a line plot.
public struct GlowingIndicator: View {
    
    @State var isGlowing: Bool = false
    @Environment(\.graphLinePlotConfig) var graphLinePlotConfig
    
    public init() {}
    
    private var glowingAnimation: Animation {
        Animation
            .easeInOut(duration: graphLinePlotConfig.glowingIndicatorGlowAnimationDuration)
            .delay(graphLinePlotConfig.glowingIndicatorDelayBetweenGlow)
            .repeatForever(autoreverses: false)
    }
    
    private var glowingBackground: some View {
        Circle()
            .scaleEffect(isGlowing ? graphLinePlotConfig.glowingIndicatorBackgroundScaleEffect : 1)
            .opacity(isGlowing ? 0.0 : 1)
            .animation(glowingAnimation, value: self.isGlowing)
            .frame(width: graphLinePlotConfig.glowingIndicatorWidth,
                   height: graphLinePlotConfig.glowingIndicatorWidth)
    }
    
    public var body: some View {
        Circle()
            .frame(width: graphLinePlotConfig.glowingIndicatorWidth,
                   height: graphLinePlotConfig.glowingIndicatorWidth)
            .background(glowingBackground)
            .onAppear {
                withAnimation {
                    self.isGlowing = true
                }
            }
            .onDisappear {
                withAnimation {
                    self.isGlowing = false
                }
        }
    }
}


struct GlowingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GlowingIndicator()
        }.previewLayout(.fixed(width: 200, height: 200))
    }
}
