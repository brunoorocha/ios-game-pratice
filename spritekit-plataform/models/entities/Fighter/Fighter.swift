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
    
    var fighterDirection: PlayerSide = .right
    var isDown: Bool = false
    var positionDyDownTapped: CGFloat = 0
    
    var health : CGFloat = 100
    var damage : CGFloat = 25
    
    let rangerAttack : CGFloat = 10
    let heightAttack : CGFloat = 10

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
            self.isDown = false
        }
        // Natural Fall
        if ((node.physicsBody?.velocity.dy)! < CGFloat(0) && !self.isDown){
            node.physicsBody?.collisionBitMask |= CategoryMask.plataform
            self.stateMachine.enter(FighterFallState.self)
        }
        // Down Fall
        if ((node.physicsBody?.velocity.dy)! < CGFloat(0) && self.isDown){
            // This function are called so much
            if (node.position.y > self.positionDyDownTapped - node.size.height){
                node.physicsBody?.collisionBitMask &= ~CategoryMask.plataform
                self.stateMachine.enter(FighterFallState.self)
            }else{
                self.isDown = false
                self.positionDyDownTapped = 0
            }
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
        
        // Check position to suicide kill
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
            node.physicsBody?.collisionBitMask &= ~CategoryMask.player
            node.physicsBody?.collisionBitMask &= ~CategoryMask.suicideArea
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
            
            let hurtState = FighterHurtState(withNode: node)
            hurtState.stateAtlasTextures = AtlasTextureBuilder.build(atlas: "Hurt")
            
            let dieState = FighterDieState(withNode: node)
            dieState.stateAtlasTextures = AtlasTextureBuilder.build(atlas: "Die")
            
            self.stateMachine = GKStateMachine(states: [idleState, walkState, jumpState, attackState, fallState,hurtState, dieState])
            
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
    
    func down(){
        if let node = self.component(ofType: SpriteComponent.self)?.node {
            self.isDown = true
            self.positionDyDownTapped = node.position.y
            node.physicsBody?.collisionBitMask &= ~CategoryMask.plataform
        }
    }
    
    func attack() {
        // Necessary because resizing are bugged
        if (self.stateMachine.currentState is FighterAttackState) { return }
        if let node = self.component(ofType: SpriteComponent.self)?.node {
            // Get scene reference
            guard let scene = node.scene as? MyScene else { return }
            // Create a damage area - See more to info
            let damageArea = self.insertDamageArea(node: node)
            // Filter for fights to hit
            scene.fighters.forEach({
                if let fighterNode = $0.component(ofType: SpriteComponent.self)?.node {
                    if fighterNode.intersects(damageArea){
                        if ($0 == self) { return }
                        $0.receiveDamage(damage: self.damage)
                    }
                }
            })
        }
        self.stateMachine.enter(FighterAttackState.self)        
    }
    
    func receiveDamage(damage: CGFloat){
        self.health -= damage
        // Check if is alive
        if (health > 0) {
            self.stateMachine?.enter(FighterHurtState.self)
        }else{
            self.stateMachine?.enter(FighterDieState.self)
        }
    }
    
    func suicide(){
        self.stateMachine?.enter(FighterDieState.self)
    }
    
    /// Create the SKShapeNode which will be resposable of give damage to anothers players
    /// The shape will setter the sizes based on self properties of range attack and height attack
    /// - Parameters:
    ///   - node: The node from fighter responsible for give attack
    ///   - scene: The scene is needed when have debugger
    /// - Returns: SKShapeNode
    private func insertDamageArea(node: SKSpriteNode, scene debugger: SKScene? = nil) -> SKShapeNode{

        var pointX : CGFloat = 0
        if (self.fighterDirection == .left) {
            pointX = -self.rangerAttack
        }else{
            pointX = +node.size.width
        }
        /*
         * X < Get current position x + subtract for range attack to make outside from same body
         * : = node.frame.origin.x    + (- self.rangerAttack)
         * X > Get current position x + sum with own width to make outside from same body
         * : = node.frame.origin.x    + node.size.width
         * Y = Get the fighet floor position + get the center (Y) position + set the height area to center
         * : = node.frame.origin.y           + node.size.height/2          + ( - self.heightAttack/2 )
        **/
        let damageArea = SKShapeNode(rect: CGRect(x: node.frame.origin.x + pointX, y: node.frame.origin.y+(node.size.height/2) - self.heightAttack/2, width: self.rangerAttack, height: self.heightAttack))
        damageArea.physicsBody?.collisionBitMask = CategoryMask.none
        if let scene = debugger{
            damageArea.fillColor = .red
            scene.addChild(damageArea)
        }
        return damageArea
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
