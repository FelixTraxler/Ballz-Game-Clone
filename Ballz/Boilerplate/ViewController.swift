//
//  ViewController.swift
//  Ballz
//
//  Created by Felix Traxler on 14.09.18.
//  Copyright © 2018 Felix Traxler. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        becomeFirstResponder()
        
        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            let scene = GameScene(size: CGSize(width: 1024, height: 720))
            
            scene.scaleMode = .aspectFit
                
                // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
//            view.showsPhysics = true
//            view.showsFPS = true
//            view.showsNodeCount = true
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        skView.scene?.mouseMoved(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        skView.scene?.mouseUp(with: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        skView.scene?.mouseDown(with: event)
    }
}

