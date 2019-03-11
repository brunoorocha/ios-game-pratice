//
//  FighterKnockbackState.swift
//  spritekit-plataform
//
//  Created by Thiago Valente on 11/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class FighterKnockbackState: GKState {
    var node: SKSpriteNode!
    var stateAtlasTextures: [SKTexture] = []
    
    init(withNode node: SKSpriteNode) {
        self.node = node
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is FighterIdleState.Type || stateClass is FighterDieState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        let knockbackAction = SKAction.animate(with: self.stateAtlasTextures, timePerFrame: 0.15, resize: true, restore: true)
        node.run(knockbackAction, completion: {
            self.node.physicsBody?.velocity.dx = 0
            self.stateMachine?.enter(FighterIdleState.self)
        })
    }
}
