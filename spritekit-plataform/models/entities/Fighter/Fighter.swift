//
//  Fighter.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 21/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import GameplayKit
import SpriteKit

class Fighter: GKEntity {
    
    var stateMachine: GKStateMachine!
    
    override init() {
        super.init()
        
        let spriteComponent = SpriteComponent(withTexture: SKTexture(imageNamed: ""))
        self.addComponent(spriteComponent)
        
        self.setupStateMachine()
        self.configurePhysicsBody()
    }
    
    func configurePhysicsBody() {
        if let node = self.component(ofType: SpriteComponent.self)?.node {
            node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
            node.physicsBody?.affectedByGravity = true
            node.physicsBody?.friction = 0
            node.physicsBody?.restitution = 0
            node.physicsBody?.allowsRotation = false
            node.physicsBody?.categoryBitMask = CategoryMask.player
            node.physicsBody?.collisionBitMask = CategoryMask.ground
        }
    }
    
    func setupStateMachine() {
        if let node = self.component(ofType: SpriteComponent.self)?.node {
            let idleState = FighterIdleState(withNode: node)
            idleState.stateAtlasTextures = AtlasTextureBuilder.build(atlas: "Idle")
            
            let walkState = FighterWalkState(withNode: node)
            walkState.stateAtlasTextures = AtlasTextureBuilder.build(atlas: "Run")
            
            let jumpState = FighterJumpState(withNode: node)
            jumpState.stateAtlasTextures = AtlasTextureBuilder.build(atlas: "Jump")
            
            let attackState = FighterAttackState(withNode: node)
            attackState.stateAtlasTextures = AtlasTextureBuilder.build(atlas: "Attack")
            
            self.stateMachine = GKStateMachine(states: [idleState, walkState, jumpState, attackState])
            
            self.idle()
        }        
    }
    
    @objc func idle() {
        self.stateMachine.enter(FighterIdleState.self)
    }
    
    func walk(inDirectionX dx: CGFloat) {
        if let node = self.component(ofType: SpriteComponent.self)?.node {
            let nodeDirection: CGFloat = dx < 0 ? -1.0 : 1.0
            node.xScale = abs(node.xScale) * nodeDirection
            self.stateMachine.enter(FighterWalkState.self)
        }
    }
    
    func jump() {
        self.stateMachine.enter(FighterJumpState.self)
    }
    
    func attack() {
        self.stateMachine.enter(FighterAttackState.self)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
