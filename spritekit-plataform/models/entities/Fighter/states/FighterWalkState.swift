//
//  FighterWalkState.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 22/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//


import SpriteKit
import GameplayKit

class FighterWalkState: GKState {
    var node: SKSpriteNode!
    var stateAtlasTextures: [SKTexture] = []
    var dx: CGFloat = 1.0
    
    init(withNode node: SKSpriteNode) {
        self.node = node
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is FighterIdleState.Type:
            return true
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
        let walkAction = SKAction.animate(with: self.stateAtlasTextures, timePerFrame: 0.15, resize: true, restore: true)
        let nodeDirection: CGFloat = node.xScale < 0 ? -1.0 : 1.0
        node.physicsBody?.applyImpulse(CGVector(dx: (dx * nodeDirection), dy: 0.0))
        node.run(SKAction.repeatForever(walkAction), withKey: "FighterWalkAction")
    }
}
