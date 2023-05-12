import Foundation
import Granite
import MarbleKit
import SwiftUI

extension Canvas {
    
    
    public var view: some View {
        MetalViewUI(
            texture: center.$state.binding.liveTexture,
            options: center.$state.binding.metalViewOptions) //{ gestures in
//
//            if let oldGestures = state.config?.environment.gestures {
//
//                let update = MarbleCatalog.Environment.Gestures.prepare(
//                    oldGestures,
//                    willSet: (
//                        gestures.pan.state.asMarbleEvent,
//                        gestures.scale.pinch.state.asMarbleEvent,
//                        gestures.pan.state.asMarbleEvent,
//                        gestures.scroll.state))
//
//
//                if let pan = update.identityPan {
//
//                    gestures.pan.setTranslation(
//                        pan,
//                        in: state.metalView)
//                }
//
////                    if let pinch = update.identityPinch {
////                        #if os(macOS)
////
////                        gestures.pinch.magnification = min(gestures.pinch.magnification, pinch)
////                        #else
////                        gestures.pinch.scale = min(gestures.pinch.scale, pinch)
////
////                        #endif
////                    }
//
//                if let rotate = update.identityRotate {
//                    gestures.rotate.rotation = rotate
//                }
//            }
//            state.config?.environment.updateGestures(
//                .init(
//                    pinch: (gestures.scale.pinch.state.asMarbleEvent,
//                            gestures.scale.scale),
//                    pan: (gestures.pan.state.asMarbleEvent,
//                          gestures.pan.translation(in: state.metalView)),
//                    tap: nil,
//                    rotate: ((gestures.rotate.rotation != .zero) ? gestures.rotate.state.asMarbleEvent : nil,
//                    gestures.rotate.rotation),
//                    scroll: (gestures.scroll.state != .changed ? nil : MarbleUXEvent.changed, gestures.scroll.normalizedY)))
//        }
//
////            VStack {
////
////
////                HStack {
////                    GraniteButtonComponent.init(state: .init("+", action: {sendEvent(CanvasEvents.Depth.Adjust.init(value: 0.01))}))
////                    GraniteButtonComponent.init(state: .init("-", action: {sendEvent(CanvasEvents.Depth.Adjust.init(value: -0.01))}))
////                }
////                Spacer()
////            }
    }
}
