//
//  SpriteComponent.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 21/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import GameplayKit
import SpriteKit

class SpriteComponent: GKComponent {
    var node: SKSpriteNode!
    var nameLabel: SKLabelNode!
    init(withTexture texture: SKTexture) {
        node = SKSpriteNode(texture: texture, color: .white, size: texture.size())
        nameLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        nameLabel.fontColor = SKColor(red: 255/255, green: 79/255, blue: 68/255, alpha: 1)
        nameLabel.position = CGPoint(x: 0, y: 20)
        nameLabel.fontSize = 10
        node.addChild(nameLabel)
        super.init()
    }    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
