//
//  RunCanvasExpedition.swift
//  marble
//
//  Created by 0xKala on 2/26/21.
//  Copyright (c) 2021 Stoic Collective, LLC.. All rights reserved.
//
import Granite
import Combine
import Foundation
import MarbleKit
import MetalKit

struct RunCanvasExpedition: GraniteReducer {
    typealias Center = Canvas.Center
    
    func reduce(state: inout Center.State) {
        
        guard state.stage == .prepared else { return }
        
        guard let config = state.config else {
            GraniteLogger.info("no config", .expedition, focus: true)
            return
        }
        
        let context = state.metalContext
        
        guard let currentTexture = state.currentTexture else {
            GraniteLogger.info("no current texture", .expedition, focus: true)
            return
        }
        
        let depthPaylod: MarbleCatalog.DepthPayload = .init(
            depthDataMap: state.depthTexture,
            environment: config.environment)
        
        let layers: [MarbleLayer] = state.filter.effects.map {
            .init($0.getLayer(state.glassSample, threshold: $0 == .depth ? state.depthLevel : 1.0))
        }
        
        let composite: MarbleComposite = .init(
            resource: .init(
                textures: .init(main: currentTexture),
                size: currentTexture.size),
            payload: .init(depth: depthPaylod),
            layers: layers)

        let compiled = config.engines.marble.compile(
            fromContext: context,
            forComposite: composite)
        
        //state.lastDepthMarbleTexture = compiled.payload?.depth?.depthDataMap
        
        guard let mainTexture = compiled.resource?.textures?.main else {
            GraniteLogger.info("no texture created", .expedition, focus: true)
            return
        }
        
        /*
         This step is deprecated for now
         */
//        let generatedTexture = try? config
//            .assistantExpand
//            .pipeline
//            .textureScaleableIO
//            .run(on: mainTexture)
        state.liveTexture = mainTexture
//        state.metalView.currentTexture = mainTexture
        state.glassSample = Float((Double(arc4random()) / 0xFFFFFFFF) * (2 - 1) + 1)
        state.time = CFAbsoluteTimeGetCurrent()
//        switch config.canvasType {
//        case .snapshot:
//            break
////            if state.installation.creativeMarbledData == nil {
////                guard let data = config.engines.marble.snapshot(texture: mainTexture,
////                                                                      fromContext: context) else {
////                    GraniteLogger.info("snapshot failed at texture -> data", .expedition, focus: true)
////                    return
////                }
////
////                guard let image = GraniteImage.init(data: data) else {
////                    GraniteLogger.info("snapshot failed at data -> image", .expedition, focus: true)
////                    return
////                }
////
////                guard let cropped = image.crop(size: .init(image.width, image.width), padding: .init(x: 0, y: -24)) else {
////
////                    GraniteLogger.info("snapshot failed at image -> cropped", .expedition, focus: true)
////                    return
////                }
////
////                //Send the data back to the Installation container to store
//////                connection.request(InstallationEvents.Snapshot.init(data: cropped.pngData() ?? data,
//////                                                                    image: cropped),
//////                                                                    .contact)
////                //Clear the installation config as it is expensive and holds a MetalView
////                state.config = nil
////                GraniteLogger.info("snapshot created", .expedition, focus: true)
////                return
////            }
//        default:
////            GraniteLogger.info("running - \(generatedTexture == nil)", .expedition, focus: true)
////            state.liveTexture = mainTexture
//            state.metalView.currentTexture = mainTexture
//            break
//        }
//
        GraniteLogger.info("run", .expedition, focus: true)
        guard state.type == .exhibit else { return }
    }
}
