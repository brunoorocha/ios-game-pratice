//
//  ParallaxBackground.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 12/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

class ParallaxBackground {
    var layer = 1
    var camera: SKCameraNode!
    var node: SKSpriteNode!
    var dx: CGFloat = 2.0
    var dy: CGFloat = 2.0
    
    init(withCamera camera: SKCameraNode, andNode node: SKSpriteNode) {
        self.camera = camera
        self.node = node
    }
    
    func update() {
        let newPositionX = self.camera.position.x / (self.dx - CGFloat((self.layer * 2) / 10))
        let newPositionY = self.camera.position.y / (self.dy - CGFloat((self.layer * 2) / 10))
        self.node.position = CGPoint(x: newPositionX, y: newPositionY)
    }
}
