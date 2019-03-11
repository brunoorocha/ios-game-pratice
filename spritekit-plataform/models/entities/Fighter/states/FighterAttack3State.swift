//
//  FighterAttack3State.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 01/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class FighterAttack3State: GKState {
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
        case is FighterDieState.Type:
            return true
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        let attackAction = SKAction.animate(with: self.stateAtlasTextures, timePerFrame: 0.1, resize: true, restore: true)
        node.run(attackAction, completion: {
            self.stateMachine?.enter(FighterIdleState.self)
        })
    }
}
