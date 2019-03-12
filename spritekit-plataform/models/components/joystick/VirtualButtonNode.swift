//
//  VirtualButtonNode.swift
//  PlatformerGame
//
//  Created by João Paulo de Oliveira Sabino on 12/03/19.
//  Copyright © 2019 João Paulo de Oliveira Sabino. All rights reserved.
//

import SpriteKit

class VirtualButtonNode: SKNode {
    var shape : SKShapeNode!
    var actionBlock : (() -> Void)?
    override init() {
        super.init()
    }
    
    convenience init(radius: CGFloat, fillColor: SKColor, inPosition: CGPoint){
        self.init()
        self.isUserInteractionEnabled = true
        shape = SKShapeNode(circleOfRadius: radius)
        shape.fillColor = fillColor
        shape.strokeColor = SKColor.clear
        shape.alpha = 0.5
        self.position = inPosition
        shape.position = position
        addChild(shape)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let block = actionBlock {
            block()
        }
        self.run(SKAction.fadeAlpha(to: 0.2, duration: 0.1))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.run(SKAction.fadeAlpha(to: 1, duration: 0.2))
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.run(SKAction.fadeAlpha(to: 1, duration: 0.2))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
