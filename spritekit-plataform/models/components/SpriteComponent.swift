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
    
    init(withTexture texture: SKTexture) {
        node = SKSpriteNode(texture: texture, color: .white, size: texture.size())        
        super.init()
    }    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
