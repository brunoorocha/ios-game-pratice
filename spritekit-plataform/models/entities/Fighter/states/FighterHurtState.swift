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
        if stateClass is FighterAttackState.Type {
            return false
        }
        return stateClass is FighterIdleState.Type || stateClass is FighterDieState.Type || stateClass is FighterKnockbackState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        let hurtAction = SKAction.animate(with: self.stateAtlasTextures, timePerFrame: 0.15, resize: true, restore: true)
        let hurtSound = SKAction.playSoundFileNamed("FighterHurt.wav", waitForCompletion: true)
    
        let colorize = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.2)
        node.run(colorize){
            let noColor = SKAction.colorize(with: .white, colorBlendFactor: 1, duration: 0.2)
            self.node.run(noColor)
        }
        
        
        node.run(SKAction.group([hurtAction, hurtSound]), completion: {
            self.stateMachine?.enter(FighterIdleState.self)
        })
    }
}

