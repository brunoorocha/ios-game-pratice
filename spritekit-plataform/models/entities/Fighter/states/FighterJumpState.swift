//
//  FighterJumpState.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 22/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class FighterJumpState: GKState {
    var node: SKSpriteNode!
    var stateAtlasTextures: [SKTexture] = []
    
    init(withNode node: SKSpriteNode) {
        self.node = node
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is FighterIdleState.Type:
            return true
        case is FighterWalkState.Type:
            return true
        case is FighterFallState.Type:
            return true
        case is FighterDieState.Type:
            return true
        case is FighterAttackState.Type:
            return true
        case is FighterAttack2State.Type:
            return true
        case is FighterAttack3State.Type:
            return true
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        let jumpAction = SKAction.animate(with: self.stateAtlasTextures, timePerFrame: 0.15, resize: true, restore: true)
        let jumpSound = SKAction.playSoundFileNamed("FighterJump.wav", waitForCompletion: true)
        node.run(SKAction.group([jumpAction, jumpSound]), completion: {
            self.stateMachine?.enter(FighterIdleState.self)
        })
    }
}
