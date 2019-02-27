//
//  FighterDieState.swift
//  spritekit-plataform
//
//  Created by Thiago Valente on 27/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class FighterDieState: GKState {
    var node: SKSpriteNode!
    var stateAtlasTextures: [SKTexture] = []
    
    init(withNode node: SKSpriteNode) {
        self.node = node
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        self.node.physicsBody?.velocity.dx = 0
        let dieAction = SKAction.animate(with: self.stateAtlasTextures, timePerFrame: 0.15, resize: true, restore: true)
        node.run(dieAction, completion: {
            // Stop forever loops
            self.node.removeAllActions()
            // Temporarily - Used because dead texture are bugged
            self.node.removeFromParent()
        })
    }
}


