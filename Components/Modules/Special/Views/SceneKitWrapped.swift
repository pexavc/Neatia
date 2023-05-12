//
//  SceneKitWrapped.swift
//  * stoic
//
//  Created by PEXAVC on 1/11/21.
//

import Foundation
import SceneKit
import SceneKit.ModelIO
import SwiftUI

struct SCNNodes {
    var cameraNode: SCNNode {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 24)
        cameraNode.rotation = SCNVector4(0, 0, 0, 0)
        return cameraNode
    }
    
    var lightNode: SCNNode {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        
        return lightNode
    }
    
    var ambientLightNode: SCNNode {
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        #if os(iOS)
        ambientLightNode.light!.color = UIColor.darkGray
        #else
        ambientLightNode.light!.color = NSColor.darkGray
        #endif
        
        return ambientLightNode
    }
    
    var alexanderNode: SCNNode {
        let path = Bundle.main.path(forResource: "alexander", ofType: "obj")
        let url = NSURL(fileURLWithPath: path!)
        let materialPath = Bundle.main.path(forResource: "alexander", ofType: "jpg")
        let materialURL = NSURL(fileURLWithPath: materialPath!)
        let asset = MDLAsset(url: url as URL)
        
        
        let scatteringFunction = MDLScatteringFunction.init()
        let material = MDLMaterial.init(name: "baseMaterial", scatteringFunction: scatteringFunction)
        
        let property = MDLMaterialProperty.init(name: "baseMaterial", semantic: .baseColor, url: materialURL as URL)
        material.setProperty(property)
        
        for mesh in ((asset.object(at: 0) as? MDLMesh)?.submeshes as? [MDLSubmesh]) ?? [] {
          mesh.material = material
        }
        
        asset.loadTextures()
        
        guard let object = asset.object(at: 0) as? MDLMesh
             else { fatalError("Failed to get mesh from asset.") }
        
        let alexanderNode = SCNNode(mdlObject: object)
        return alexanderNode
    }
}

#if os(OSX)
import AppKit
struct SceneKitView : NSViewRepresentable {
    
    let scnView: SCNView = .init()
    let scene = SCNScene.init()
    let nodes: SCNNodes = .init()
    let action: SCNAction = SCNAction.repeatForever(SCNAction.rotateBy(x: -2, y: 2, z: 0, duration: 57))
    let actionWarmer: SCNAction = SCNAction.rotateBy(x: -2, y: 2, z: 0, duration: 1.0)

    func makeNSView(context: NSViewRepresentableContext<SceneKitView>) -> SCNView {
        
        scene.rootNode.addChildNode(nodes.cameraNode)
        scene.rootNode.addChildNode(nodes.lightNode)
        scene.rootNode.addChildNode(nodes.ambientLightNode)
        scene.rootNode.addChildNode(nodes.alexanderNode)
    
        scnView.scene = scene
        
        return scnView
    }

    func updateNSView(_ scnView: SCNView, context: Context) {
        scnView.allowsCameraControl = true
        scnView.backgroundColor = NSColor(Brand.Colors.black)
    }
    
    func run() {
        scene.rootNode.runAction(action)
    }
    
    func clear() {
        scene.rootNode.removeAllActions()
        scene.rootNode.cleanup()
    }
}

#else
import UIKit

struct SceneKitView : UIViewRepresentable {
    
    let scene = SCNScene.init()
    let nodes: SCNNodes = .init()
    let action: SCNAction = SCNAction.repeatForever(SCNAction.rotateBy(x: -2, y: 2, z: 0, duration: 57))

    func makeUIView(context: UIViewRepresentableContext<SceneKitView>) -> SCNView {
   
        scene.rootNode.addChildNode(nodes.cameraNode)
        scene.rootNode.addChildNode(nodes.lightNode)
        scene.rootNode.addChildNode(nodes.ambientLightNode)
        scene.rootNode.addChildNode(nodes.alexanderNode)
        
        let scnView = SCNView()
        scnView.scene = scene
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor(Brand.Colors.black)
    }
    
    func run() {
        scene.rootNode.runAction(action)
    }
    
    func clear() {
        scene.rootNode.removeAllActions()
        scene.rootNode.cleanup()
    }
}
#endif

extension SCNNode {
    func cleanup() {
        for child in childNodes {
            child.cleanup()
        }
        geometry = nil
        removeFromParentNode()
    }
}
