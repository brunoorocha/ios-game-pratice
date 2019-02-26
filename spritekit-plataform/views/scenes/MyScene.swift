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
        
        // Temporarily
//        Map1(withScene: self)
        var fighters: [Fighter] = []
        fighters.append(self.fighter)
        Map1(withScene: self, andFighters: fighters)
        
        self.configureStates()
        self.entityManager.add(entity: fighter)
        self.configureGesturePad(for: view)
        self.configureCamera()
        self.configurePhysics()
    }
    
    func configureStates() {
        let prepareState = PrepareFightState(withScene: self)
        let fightingState = FightingState(withScene: self)
        self.stateMachine = GKStateMachine(states: [prepareState, fightingState])
//        self.stateMachine.enter(PrepareFightState.self)
        self.stateMachine.enter(FightingState.self)
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
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == CategoryMask.player | CategoryMask.plataform{
            // Plataform Idle
            if contact.bodyA.node?.physicsBody?.categoryBitMask == CategoryMask.player{
                self.playerDidCollideWithPlataform(player: contact.bodyA.node!, plataform: contact.bodyB.node!)
            }else{
                self.playerDidCollideWithPlataform(player: contact.bodyB.node!, plataform: contact.bodyA.node!)
            }
        }
        if collision == CategoryMask.player | CategoryMask.ground{
            if contact.bodyA.node?.physicsBody?.categoryBitMask == CategoryMask.player{
                contact.bodyA.node!.physicsBody?.collisionBitMask &= ~CategoryMask.plataform
            }else{
                contact.bodyB.node!.physicsBody?.collisionBitMask &= ~CategoryMask.plataform
            }
        }

    }
    
    private func playerDidCollideWithPlataform(player: SKNode, plataform: SKNode){
        if plataform.position.y > player.position.y{
            player.physicsBody?.collisionBitMask &= ~CategoryMask.plataform
        }else{
            player.physicsBody?.collisionBitMask |= CategoryMask.plataform
        }
    }

}
