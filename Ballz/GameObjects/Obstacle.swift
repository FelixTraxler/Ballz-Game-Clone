//
//  Obstacle.swift
//  Ballz
//
//  Created by Felix Traxler on 15.09.18.
//  Copyright © 2018 Felix Traxler. All rights reserved.
//

import Foundation
import SpriteKit

class Obstacle: SKNode {
    private var shapeNode = SKShapeNode(rectOf: CGSize(width: 150, height: 30))
    
    let colors = [NSColor.green, NSColor.orange, NSColor.red]
    var lives: Int
    
    var noLivesLeft: (() -> Void)?
    
    override var frame: CGRect {
        let size = shapeNode.frame.size
        let middlePoint = super.frame.origin
        let zeroPoint = CGPoint(x: middlePoint.x - size.width / 2,
                                y: middlePoint.y - size.height / 2)
        
        return CGRect(origin: zeroPoint, size: size)
    }
    
    override init() {
        lives = colors.count
        
        super.init()
        
        shapeNode.roundCorners(radius: 10)
        shapeNode.fillColor = colors[colors.count - lives]
        shapeNode.strokeColor = .clear
        
        physicsBody = SKPhysicsBody(polygonFrom: shapeNode.path!)
        physicsBody!.categoryBitMask    = PhysicsCategory.Obstacle
        physicsBody!.collisionBitMask   = PhysicsCategory.Ball
        physicsBody!.contactTestBitMask = PhysicsCategory.Ball
        physicsBody!.isDynamic = false
        

        addChild(shapeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func wasHit() {
        lives -= 1
        
        if lives == 0 {
            removeFromParent()
            noLivesLeft?()
        } else {
            shapeNode.fillColor = colors[colors.count - lives]
        }
    }
}
