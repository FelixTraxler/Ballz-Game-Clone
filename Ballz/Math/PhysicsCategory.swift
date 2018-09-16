//
//  PhysicsCategory.swift
//  Ballz
//
//  Created by Felix Traxler on 14.09.18.
//  Copyright © 2018 Felix Traxler. All rights reserved.
//

import Foundation

class PhysicsCategory {
    static let None:        UInt32 = 0
    static let World:       UInt32 = 0b1
    static let Player:      UInt32 = 0b10
    static let Ball:        UInt32 = 0b100
    static let Obstacle:    UInt32 = 0b1000
    static let Ground:      UInt32 = 0b10000
}
