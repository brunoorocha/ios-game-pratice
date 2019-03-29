//
//  FighterAttackState.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 22/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class FighterAttackState: GKState {
    var node: SKSpriteNode!
    var stateAtlasTextures: [SKTexture] = []
    
    init(withNode node: SKSpriteNode) {
        self.node = node
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is FighterIdleState.Type:
            return true
        case is FighterDieState.Type:
            return true
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        let attackAction = SKAction.animate(with: self.stateAtlasTextures, timePerFrame: 0.1, resize: true, restore: true)
        if let _ = self.node.parent, self.node.alpha > 0.1{
            // Run Sound
            FighterSound.run(type: .attack)
        }
        node.run(attackAction) {
            self.stateMachine?.enter(FighterIdleState.self)
        }
    }
}
