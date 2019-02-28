//
//  FighterHurtState.swift
//  spritekit-plataform
//
//  Created by Thiago Valente on 27/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class FighterHurtState: GKState {
    var node: SKSpriteNode!
    var stateAtlasTextures: [SKTexture] = []
    
    init(withNode node: SKSpriteNode) {
        self.node = node
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is FighterIdleState.Type || stateClass is FighterDieState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        let hurtAction = SKAction.animate(with: self.stateAtlasTextures, timePerFrame: 0.15, resize: true, restore: true)
        node.run(hurtAction, completion: {
            self.stateMachine?.enter(FighterIdleState.self)
        })
    }
}

