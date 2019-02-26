//
//  MyScene.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 21/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class MyScene: SKScene {
    var gesturePad: GesturePad!
    var fighter: Fighter!
    var entityManager: EntityManager!
    var stateMachine: GKStateMachine!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.white
        self.entityManager = EntityManager(withScene: self)
        
        self.fighter = Fighter()
        if let fighterSpriteComponent = self.fighter.component(ofType: SpriteComponent.self) {
            fighterSpriteComponent.node.position = CGPoint(x: -200, y: 50)
        }
        
        self.configureStates()
        self.entityManager.add(entity: fighter)
        self.configureGesturePad(for: view)
        self.configureCamera()
        self.configurePhysics()
        self.drawFloor()
    }
    
    func configureStates() {
        let prepareState = PrepareFightState(withScene: self)
        let fightingState = FightingState(withScene: self)
        self.stateMachine = GKStateMachine(states: [prepareState, fightingState])
        self.stateMachine.enter(PrepareFightState.self)
//        self.stateMachine.enter(FightingState.self)
    }
    
    func configurePhysics() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
    }
    
    func configureCamera() {
        let camera = SKCameraNode()
//        camera.setScale(0.5)
        self.camera = camera
        self.addChild(camera)
    }
    
    func configureGesturePad(for view: SKView) {
        self.gesturePad = GesturePad(forView: view)
        self.gesturePad.delegate = self
    }
    
    private func drawFloor(){
        let y = CGFloat(-80.0)
        let area = SKShapeNode(rect: CGRect(x: -self.size.width/2, y: y, width: self.size.width, height: 50))
        area.fillColor = .lightGray
        area.physicsBody = SKPhysicsBody(edgeLoopFrom: area.frame)
        area.physicsBody?.categoryBitMask = CategoryMask.ground
        area.physicsBody?.collisionBitMask = CategoryMask.player
        area.physicsBody?.affectedByGravity = false
        area.physicsBody?.restitution = 0
        self.addChild(area)
    }
}

extension MyScene: GesturePadDelegate {
    func performActionForAnalogMoving(inAngle angle: CGFloat, withDirectionX dx: CGFloat, AndDirectionY dy: CGFloat) {
        self.fighter.walk(inDirectionX: dx)
    }
    
    func performActionForAnalogStopMoving() {
        self.fighter.idle()
    }
    
    func performActionForTap() {
        self.fighter.attack()
    }
    
    func performActionForSwipe() {
        self.fighter.jump()
    }
    
}

extension MyScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let _ = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    }
}
