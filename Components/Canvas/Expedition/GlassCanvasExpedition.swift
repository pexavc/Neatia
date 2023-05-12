////
////  GlassCanvasExpedition.swift
////  lamarque
////
////  Created by 0xKala on 3/16/21.
////
//
//import Granite
//import Combine
//import Foundation
//import MarbleKit
//import MetalKit
//
//struct GlassCanvasExpedition: GraniteReducer {
//    typealias Center = Canvas.Center
//    
//    func reduce(state: inout Center.State) {
//        
//        state.glassSample = event.sample
//        state.glassFrames += 1
//        if state.glassSample > 12, state.glassFrames > 1200 {
//            state.glassFrames = 0
//            connection.request(InstallationEvents.Advance(), .contact)
//        }
//        
//        //Prevent Overflow?
//        if state.glassFrames > 120000 {
//            state.glassFrames = 0
//        }
//    }
//}
