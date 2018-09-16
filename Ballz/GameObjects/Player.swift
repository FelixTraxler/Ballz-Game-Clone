//
//  Player.swift
//  Ballz
//
//  Created by Felix Traxler on 14.09.18.
//  Copyright © 2018 Felix Traxler. All rights reserved.
//

import Foundation
import SpriteKit

 class Player: SKNode {
    
    static let Size = CGSize(width: 100, height: 20)
    
    private let shapeNode = SKShapeNode(rectOf: Player.Size)
    
    private let movePointsPerMillisecond: Double = 1
    private var targetX: CGFloat
    
    private var currentHue: CGFloat = 0
    
    override init() {
        targetX = 0
        
        super.init()
        
        shapeNode.roundCorners(radius: 5)
        shapeNode.fillColor = NSColor(hue: CGFloat(currentHue), saturation: 1, brightness: 1, alpha: 1.0)
        shapeNode.strokeColor = .clear
        
        physicsBody = SKPhysicsBody(polygonFrom: shapeNode.path!)
        physicsBody!.isDynamic = false
        
        physicsBody!.categoryBitMask    = PhysicsCategory.Player
        physicsBody!.collisionBitMask   = PhysicsCategory.Ball
        physicsBody!.contactTestBitMask = PhysicsCategory.Ball
        
        addChild(shapeNode)
        
        targetX = frame.midX
    }
    
    required init?(coder aDecoder: NSCoder) {
        targetX = 0
        super.init(coder: aDecoder)
    }
    
    func move(until xPosition: CGFloat) {
        targetX = xPosition
    }
    
    func update(_ delta: Milliseconds) {
        currentHue += CGFloat(delta / 2000.0)
        
        if currentHue > 1 {
            currentHue -= 1
        }
        
        shapeNode.fillColor = NSColor(hue: currentHue, saturation: 1, brightness: 1, alpha: 1.0)
        
        if targetX < shapeNode.frame.width / 2 || targetX > parent!.frame.maxX - shapeNode.frame.width / 2 {
            return
        }
        
        position.x = targetX
    }
}
