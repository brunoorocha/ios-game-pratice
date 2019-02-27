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
    var fighters : [Fighter] = []
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.white
        self.entityManager = EntityManager(withScene: self)
        
        self.fighter = Fighter()
        if let fighterSpriteComponent = self.fighter.component(ofType: SpriteComponent.self) {
            fighterSpriteComponent.node.position = CGPoint(x: -200, y: 50)
        }
        self.fighters.append(fighter)
        
        // Temporarily
        let guineaPig = Fighter()
        if let fighterSpriteComponent = guineaPig.component(ofType: SpriteComponent.self) {
            fighterSpriteComponent.node.position = CGPoint(x: -150, y: 50)
        }
        self.fighters.append(guineaPig)
        self.entityManager.add(entity: guineaPig)
        
        // Temporarily
        let guineaPig2 = Fighter()
        if let fighterSpriteComponent = guineaPig2.component(ofType: SpriteComponent.self) {
            fighterSpriteComponent.node.position = CGPoint(x: 50, y: 50)
        }
        self.fighters.append(guineaPig2)
        self.entityManager.add(entity: guineaPig2)
        
        // Temporarily
        Map1(withScene: self)

        
        self.configureStates()
        self.entityManager.add(entity: fighter)
        self.configureGesturePad(for: view)
        self.configureCamera()
        self.configurePhysics()
        self.suicideArea()
    }
    
    func configureStates() {
        let prepareState = PrepareFightState(withScene: self)
        let fightingState = FightingState(withScene: self)
        self.stateMachine = GKStateMachine(states: [prepareState, fightingState])

//        self.stateMachine.enter(PrepareFightState.self)
        self.stateMachine.enter(FightingState.self)
    }
    
    func configurePhysics() {
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
    }
    
    private func suicideArea(){
        let width = self.size.width*5
        let area = SKShapeNode(rect: CGRect(x: (-self.size.width/2 - width/2), y: -self.size.height/2 - 20, width: width, height: 0))
        area.fillColor = .lightGray
        area.physicsBody = SKPhysicsBody(edgeLoopFrom: area.frame)
        area.physicsBody?.categoryBitMask = CategoryMask.suicideArea
        area.physicsBody?.contactTestBitMask = CategoryMask.player
        area.physicsBody?.affectedByGravity = false
        area.physicsBody?.restitution = 0
        area.physicsBody?.friction = 0
        area.isHidden = true
        self.addChild(area)
    }
    
    func configureCamera() {
        let camera = SKCameraNode()
        camera.setScale(0.7)
        self.camera = camera
        self.addChild(camera)
    }
    
    func configureGesturePad(for view: SKView) {
        self.gesturePad = GesturePad(forView: view)
        self.gesturePad.delegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.fighter.update(deltaTime: currentTime)
        if let node = self.fighter.component(ofType: SpriteComponent.self)?.node {
            self.camera?.position = node.position
        }
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
    
    func performActionForSwipeUp() {
        self.fighter.jump()
    }
    
    func performActionForSwipeDown() {
        self.fighter.down()
    }
}

extension MyScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if ( collision == CategoryMask.player | CategoryMask.suicideArea ) {
            print("Commited suicide")
            let playerNode = contact.bodyA.categoryBitMask == CategoryMask.player ? contact.bodyA.node : contact.bodyB.node
            self.fighters.forEach({
                if let node = $0.component(ofType: SpriteComponent.self)?.node {
                    if (node == playerNode){
                        $0.suicide()
                    }
                }
            })
        }
    }
}
