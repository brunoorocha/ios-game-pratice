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
        if let _ = self.node.parent, self.node.alpha > 0.1{
            // Run Sound
            FighterSound.run(type: .jump)
        }
        node.run(jumpAction){
            self.stateMachine?.enter(FighterIdleState.self)
        }
    }
}
