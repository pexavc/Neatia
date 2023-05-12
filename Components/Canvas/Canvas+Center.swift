//
//  Canvas+Center.swift
//  PEX
//
//  Created by Ritesh Pakala on 8/8/22.
//

import Foundation
import Granite
import MarbleKit
import SwiftUI

extension Canvas {
    struct Center: GraniteCenter {
        
        public enum CanvasStage {
            case none
            case prepared
            case running
        }

        public enum CanvasType {
            case snapshot
            case exhibit
        }

        public struct CanvasFilter {
            let effects: [MarbleEffect]
        }

        struct State: GraniteState {
            @Geometry var geometry: GeometryProxy?
            
            public static func == (lhs: Canvas.Center.State, rhs: Canvas.Center.State) -> Bool {
                lhs.time == rhs.time
            }
            
            enum CodingKeys: CodingKey {
                case time
            }
            
            var stage: CanvasStage = .none
            
            var localFrame: CGRect {
                geometry?.frame(in: .local) ?? .zero
            }
            
            var image: GraniteImage
            var filter: CanvasFilter = .init(effects: [.vibes])
            
            var currentTexture: MTLTexture? = nil
            var liveTexture: MTLTexture? = nil
            var depthTexture: MTLTexture? = nil
            
            var metalViewOptions: MetalViewOptions = .empty
            
            var config: InstallationConfig? = nil
            
            var glassSample: Float = 0.0
            var glassFrames: Int64 = 0
            var depthLevel: Float = 0.012
            var time = CFAbsoluteTimeGetCurrent()
            //var lastDepthMarbleTexture: MTLTexture?
            
            var metalContext: MetalContext = .init()
            
            var type: CanvasType {
                .exhibit
            }
            
            var exhibit: Bool = true
            
            public init() {
                if let url = Bundle.main.url(forResource: "test", withExtension: "png") {
                    image = UIImage(contentsOfFile: url.path) ?? .init()
                } else {
                    image = .init()
                }
            }
            
            public init(image: GraniteImage,
                        exhibit: Bool) {
                self.image = image
                self.exhibit = exhibit
            }
            
            init(from decoder:Decoder) throws {
                image = .init()
            }
        }
        
        @Store var state: State
        
        @Event(.onAppear) var CanvasDidAppear: PrepareCanvasExpedition.Reducer
    }
}
