//
//  PrepareCanvasExpedition.swift
//  marble
//
//  Created by 0xKala on 2/27/21.
//

import Foundation
import Granite
import SwiftUI
import Combine
import Foundation
import MarbleKit
import MetalKit
import Accelerate

struct PrepareCanvasExpedition: GraniteReducer {
    typealias Center = Canvas.Center
    
    @Relay var service: TestService
    @Event(interval: 0.016667) var CanvasRun: RunCanvasExpedition.Reducer
    
    func reduce(state: inout Center.State) {
        
        guard let model = service.center.model else { return }
        
        //This will pull an existing or create one
        let config: InstallationConfig = state.config ?? .init()

        state.metalViewOptions.contentSize = state.localFrame.size
        
        let referenceSize = MarbleCatalog.Const.defaultRes
        
        switch state.type {
        case .snapshot, .exhibit:
           /*
         
             (far - left) 180 - 135 (middle)
             (far - right) 0 - 45 (middle)
           
            */
            //Randomize location, starting location of the camera
//            let panLeftWindow: Int = Int.random(in: 12..<18) * 10
//            let panRightWindow: Int = Int.random(in: 0..<5) * 10
//            let panChance: Int = (Int.random(in: 0..<3))
//            let pan: Int = panChance < 1 ? panLeftWindow : panRightWindow
//
            state.metalViewOptions.scalingMode = .scaleAspectFit
            state.metalViewOptions.rotation = 0
            
//            state.metalView.metalContext.kernels.filters.depth.updateCameraPan(startingPan: pan,
//                                                                               res: referenceSize)
            
            if state.image.size.isLandscape {
//                state.metalView.metalContext.kernels.filters.depth.updateStartingZoom(startingZoom: 270)
                state.metalViewOptions.startingZoom = 270
                state.metalViewOptions.rotation = 180
            }
//            if EnvironmentConfig.isIPhone {
//                if state.image.size.isLandscape {
//                    state.metalView.metalContext.kernels.filters.depth.updateStartingZoom(startingZoom: 270)
//
//                    state.metalView.inputVideoRotation = 180
//                }
//            } else {
//                state.metalView.metalContext.kernels.filters.depth.updateStartingZoom(startingZoom: 400)
//            }
//        case .exhibit:
            //
            break
        }
        
//        config.updateAssistantAdaptive(state.metalView.mtkView.drawableSize)
        config.updateAssistantAdaptive(state.metalViewOptions.contentSize)
        
        guard let texture: MTLTexture = try? config
                    .assistant
                    .pipeline
                    .imageIO.run(on: state.image) else { return }
        
        
        /*
         Proper aspect of input texture
         */
        let aspect = texture.size.isLandscape ? CGFloat(texture.size.width / texture.size.height) : CGFloat(texture.size.height / texture.size.width)
        
        /*
         Scale to Marble's optimal dimensions
         */
        let width = max(min(CGFloat(state.localFrame.size.width), referenceSize.width), referenceSize.width)
        let height = width*aspect
        
        
        /*
         Scale Depth Texture to the dimensions of the input
         
         we use `aspectFill, to allow resizing on all screens to avoid
         really really tiny renderings on let's say, iPhones`
         
         This will cause really large outputs so we will scale down
         after.
         */
        let textureSize: CGSize = model.features.inputSize
        let rect = textureSize.position(
            in: .init(
                width: width,
                height: height),
            with: ScalingMode.scaleAspectFit)
        
        /*
         Reverse Width and Height for Camera Intrinsic to appropriate
         This is found in the PointCloud.metal shader for the Depth Filter
         
         As the depth model will output an image that is a mirror copy over
         y and x
         */
        let newWidth: CGFloat
        let newHeight: CGFloat
        //Investigate why we need this special case for landscape
        //otherwise the output is way to stretched out
        if texture.size.isLandscape {
            newWidth = rect.height
            newHeight = rect.width
        } else {
            newWidth = height
            newHeight = width
        }
         
        /*
         Update the utility for scaling in the next expedition
         */
        config.updateAssistantDepth(.init(width: newWidth, height: newHeight))
        
        guard let buffer = state.image.resize(withSize: model.features.inputSize)?.pixelBuffer() else { return }
        guard let depthMap = model.predict(buffer) else {
            return
        }
        
        let mm = depthMap
        let length = mm.count
        let doublePtr =  mm.dataPointer.bindMemory(to: Float.self, capacity: length)
        let doubleBuffer = UnsafeBufferPointer(start: doublePtr, count: length)
        let output = Array(doubleBuffer)
        
        guard let max = output.max(), let min = output.min() else {
            return
        }
        guard let depthMapCG = depthMap.cgImage(min: Double(min), max: Double(max)) else {
            return
        }
        
        let depthMapImage: MarbleImage
            
        #if os(macOS)
        depthMapImage = MarbleImage.init(cgImage: depthMapCG, size: model.features.inputSize).flipped(flipHorizontally: false, flipVertically: true)
        #else
        
        depthMapImage = MarbleImage.init(cgImage: depthMapCG)
        #endif
        
//        guard let depthBuffer = MetalAssistant.makeMetalCompatible(depthMap) else {
//            return
//        }
//
        guard let depthTexture = try? config
            .depthAssistant
            .pipeline
            .imageIO
            .run(on: depthMapImage) else {
            return

        }

        guard let resized = try? config
            .depthAssistant
            .pipeline
            .textureScaleableIO
            .run(on: depthTexture) else {
            return
        }

        state.currentTexture = texture
        state.depthTexture = resized

        state.config = config

        state.stage = .prepared
//
//
////        connection.request(CanvasEvents.Run())
        GraniteLogger.info("prepared canvas", .expedition, focus: true)
    }
}
