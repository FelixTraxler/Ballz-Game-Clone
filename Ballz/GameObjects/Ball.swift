//
//  Ball.swift
//  Ballz
//
//  Created by Felix Traxler on 14.09.18.
//  Copyright © 2018 Felix Traxler. All rights reserved.
//

import Foundation
import SpriteKit

class Ball: SKNode {
    
    static let Radius: CGFloat = 20
    
    private let shapeNode = SKShapeNode(circleOfRadius: Ball.Radius)
    
    private var parentFrame: CGRect {
        return parent?.frame ?? .zero
    }
    private var currentHue: CGFloat = 0
        
    override var frame: CGRect {
        let origin = super.frame.origin
        let size = shapeNode.frame.size
        let middle = CGPoint(x: origin.x - size.width / 2, y: origin.y - size.height / 2)
        
        return CGRect(origin: middle, size: size)
    }
    
    override init() {
        super.init()
        
        shapeNode.fillColor = NSColor(hue: currentHue, saturation: 1, brightness: 1, alpha: 1.0)
        shapeNode.strokeColor = .clear
        
        physicsBody = SKPhysicsBody(circleOfRadius: Ball.Radius)
        
        physicsBody!.friction = 0.0
        physicsBody!.linearDamping = 0.0
        physicsBody!.restitution = 1.0
        
        physicsBody!.usesPreciseCollisionDetection = true
        
        physicsBody!.categoryBitMask    = PhysicsCategory.Ball
        physicsBody!.collisionBitMask   = PhysicsCategory.World | PhysicsCategory.Player | PhysicsCategory.Obstacle
        physicsBody!.contactTestBitMask = PhysicsCategory.World | PhysicsCategory.Player
        
        addChild(shapeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ delta: Milliseconds) {
        currentHue += CGFloat(delta / 2000.0)
        
        if currentHue > 1 {
            currentHue -= 1
        }
        
        shapeNode.fillColor = NSColor(hue: currentHue, saturation: 1, brightness: 1, alpha: 1.0)
    }
}
