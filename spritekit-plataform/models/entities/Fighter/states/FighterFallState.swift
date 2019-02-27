//
//  FighterFallState.swift
//  spritekit-plataform
//
//  Created by Thiago Valente on 26/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class FighterFallState: GKState {
    var node: SKSpriteNode!
    var stateAtlasTextures: [SKTexture] = []
    
    init(withNode node: SKSpriteNode){
        self.node = node
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is FighterWalkState.Type:
            return true
        case is FighterAttackState.Type:
            return true
        case is FighterIdleState.Type:
            return true
        case is FighterDieState.Type:
            return true
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        let fallAction = SKAction.animate(with: self.stateAtlasTextures, timePerFrame: 0.15, resize: true, restore: true)
        node.run(SKAction.repeatForever(fallAction), withKey: "FighterFallAction")
    }
    
}
