//
//  SK-Extensions.swift
//  Ballz
//
//  Created by Felix Traxler on 15.09.18.
//  Copyright © 2018 Felix Traxler. All rights reserved.
//

import Foundation
import SpriteKit

extension SKLabelNode {
    func addShadow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        
        let labelNode = self.copy() as! SKLabelNode
        labelNode.position.y -= 5
        labelNode.fontColor = NSColor(white: 0.5, alpha: 1)
        
        effectNode.addChild(labelNode)
        effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
    }
}

extension SKShapeNode {
    func roundCorners(radius: CGFloat){
        path = CGPath(roundedRect: frame, cornerWidth: radius, cornerHeight: radius, transform: nil)
    }
}

public enum GradientDirection {
    case Up
    case Left
    case UpLeft
    case UpRight
}

extension SKTexture {
    
    convenience init(size: CGSize, color1: CIColor, color2: CIColor, direction: GradientDirection = .Up) {
        
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CILinearGradient")
        var startVector: CIVector
        var endVector: CIVector
        
        filter!.setDefaults()
        
        switch direction {
        case .Up:
            startVector = CIVector(x: size.width * 0.5, y: 0)
            endVector = CIVector(x: size.width * 0.5, y: size.height)
        case .Left:
            startVector = CIVector(x: size.width, y: size.height * 0.5)
            endVector = CIVector(x: 0, y: size.height * 0.5)
        case .UpLeft:
            startVector = CIVector(x: size.width, y: 0)
            endVector = CIVector(x: 0, y: size.height)
        case .UpRight:
            startVector = CIVector(x: 0, y: 0)
            endVector = CIVector(x: size.width, y: size.height)
        }
        
        filter!.setValue(startVector, forKey: "inputPoint0")
        filter!.setValue(endVector, forKey: "inputPoint1")
        filter!.setValue(color1, forKey: "inputColor0")
        filter!.setValue(color2, forKey: "inputColor1")
        
        let image = context.createCGImage(filter!.outputImage!, from: CGRect(x: 0, y: 0, width: size.width, height: size.height))!
        self.init(cgImage: image)
    }
}

