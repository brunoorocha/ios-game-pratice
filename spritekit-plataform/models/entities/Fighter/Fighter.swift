//
//  Fighter.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 21/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import GameplayKit
import SpriteKit

enum PlayerSide{
    case left
    case right
}

class Fighter: GKEntity {
    
    var stateMachine: GKStateMachine!
    
    var jumpCount = 0
    var maxNumberOfJump = 2
    var isJumping = false
    var isGrounded = false
    var fighterDirection: PlayerSide = .right
    
    override init() {
        super.init()
        
        let spriteComponent = SpriteComponent(withTexture: SKTexture(imageNamed: "adventurer-idle-2-0"))
        self.addComponent(spriteComponent)
        
        self.setupStateMachine()
        self.configurePhysicsBody()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = self.component(ofType: SpriteComponent.self)?.node else { return }
        // Jump
        if ((node.physicsBody?.velocity.dy)! > CGFloat(0)){
            node.physicsBody?.collisionBitMask &= ~CategoryMask.plataform
        }
        // Fall
        if ((node.physicsBody?.velocity.dy)! < CGFloat(0)){
            node.physicsBody?.collisionBitMask |= CategoryMask.plataform
            self.stateMachine.enter(FighterFallState.self)
        }
        // If current is Fall
        if (self.stateMachine.currentState is FighterFallState) {
            // When is grounded and haven't moviment set Idle
            if ((node.physicsBody?.velocity.dy)! == CGFloat(0))
            && ((node.physicsBody?.velocity.dx)! == CGFloat(0)){
                self.stateMachine.enter(FighterIdleState.self)
            }
            // When is grounded and have moviment set Run
            else if ((node.physicsBody?.velocity.dy)! == CGFloat(0))
            && ((node.physicsBody?.velocity.dx)! != CGFloat(0)){
                self.stateMachine.enter(FighterWalkState.self)
            }
        }
    }
    
    func configurePhysicsBody() {
        if let node = self.component(ofType: SpriteComponent.self)?.node {
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
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
            
            let fallState = FighterFallState(withNode: node)
            fallState.stateAtlasTextures = AtlasTextureBuilder.build(atlas: "Fall")
            
            self.stateMachine = GKStateMachine(states: [idleState, walkState, jumpState, attackState, fallState])
            
            self.idle()
        }        
    }
    
    func idle() {
        if let node = self.component(ofType: SpriteComponent.self)?.node {
            node.physicsBody?.velocity.dx = 0.0
        }
        self.stateMachine.enter(FighterIdleState.self)
    }
    
    func walk(inDirectionX dx: CGFloat) {
        if let node = self.component(ofType: SpriteComponent.self)?.node {
            let nodeDirection: CGFloat = dx < 0 ? -1.0 : 1.0
            // If direction new is right and old isn't right
            if (nodeDirection == 1.0 && self.fighterDirection != .right) {
                self.fighterDirection = .right
                self.stateMachine.enter(FighterIdleState.self)
            }
            // If new direction is left and old isn't left
            else if (nodeDirection == -1.0 && self.fighterDirection != .left) {
                self.fighterDirection = .left
                self.stateMachine.enter(FighterIdleState.self)
            }
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
