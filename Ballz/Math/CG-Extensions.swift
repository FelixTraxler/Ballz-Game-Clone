//
//  CG-Extensions.swift
//  Ballz
//
//  Created by Felix Traxler on 14.09.18.
//  Copyright © 2018 Felix Traxler. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGVector {
    func normalized() -> CGVector {
        let len = length()
        return CGVector(dx: dx / len, dy: dy / len)
    }
    
    func length() -> CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
    
    static func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
        return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }
}

extension CGPoint {
    static func -(l: CGPoint, r: CGPoint) -> CGVector {
        return CGVector(dx: l.x - r.x, dy: l.y - r.y)
    }
}
