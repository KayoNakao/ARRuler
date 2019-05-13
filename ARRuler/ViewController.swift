//
//  ViewController.swift
//  ARRuler
//
//  Created by 中尾 佳代 on 2019/02/13.
//  Copyright © 2019 Kayo Nakao. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var textNode = SCNNode()
    var dotNodes = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
 
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first{
                addDot(in: hitResult)
            }
        }
    }
    
    func addDot(in hitResult: ARHitTestResult){
        
        if dotNodes.count >= 2 {
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        let dotGeometory = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometory.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometory)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let distance = sqrtf(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        updateText(text: "\(distance)", at: end.position, at: start.position)
    }
    
    func updateText(text: String, at position: SCNVector3, at start: SCNVector3){
        
        textNode.removeFromParentNode()
        if let camera = sceneView.pointOfView {
            textNode.orientation = camera.orientation
        }
        
        let textGeometory = SCNText(string: text, extrusionDepth: 1.0)
        textGeometory.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometory)
        if let camera = sceneView.pointOfView {
            textNode.orientation = camera.orientation
        }
        textNode.position = SCNVector3(start.x, start.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.008, 0.008, 0.008)
        
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
        
    }
}
