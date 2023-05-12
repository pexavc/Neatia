//
//  Haptic.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

#if os(iOS)
import UIKit

private func hapticFeedbackDefaultSuccess() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.success)
}

private func hapticFeedbackImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}
#endif

enum Haptic {
    static func onChangeAppColorScheme() {
        #if os(iOS)
        hapticFeedbackDefaultSuccess()
        #endif
        
    }
    
    static func onShowGraphIndicator() {
        #if os(iOS)
        hapticFeedbackImpact(style: .heavy)
        #endif
    }
    
    static func onChangeTimeMode() {
        #if os(iOS)
        hapticFeedbackImpact(style: .light)
        #endif
    }
    
    static func onChangeLineSegment() {
        #if os(iOS)
        hapticFeedbackImpact(style: .light)
        #endif
    }
    
    static func basic() {
        #if os(iOS)
        hapticFeedbackImpact(style: .light)
        #endif
    }
}
