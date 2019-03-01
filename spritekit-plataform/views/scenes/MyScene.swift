//
//  MyScene.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 21/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

class MyScene: SKScene {
    var gesturePad: GesturePad!
    var fighter: Fighter!
    var entityManager: EntityManager!
    var stateMachine: GKStateMachine!
    var fighters : [Fighter] = []
    
    private var otherPlayers : [Int: Fighter] = [:]
    var pingLabel: SKLabelNode!
    var canSendPing = true
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.white
        self.entityManager = EntityManager(withScene: self)
        
        self.fighter = Fighter()
        if let fighterSpriteComponent = self.fighter.component(ofType: SpriteComponent.self) {
            fighterSpriteComponent.node.position = CGPoint(x: 0, y: 0)
        }
        self.fighters.append(fighter)
        
        //ping label
        pingLabel = SKLabelNode(text: "ping: 0 ms, host: \(MultiplayerService.shared.selfPlayer.alias)")
        pingLabel.position = CGPoint(x: 0, y: 0)
        pingLabel.fontColor = SKColor.black
        pingLabel.fontSize = 14
        addChild(pingLabel)
        
        // Temporarily
        let guineaPig = Fighter()
        if let fighterSpriteComponent = guineaPig.component(ofType: SpriteComponent.self) {
            fighterSpriteComponent.node.position = CGPoint(x: -150, y: 50)
        }
        self.fighters.append(guineaPig)
        //self.entityManager.add(entity: guineaPig)
        
        // Temporarily
        let guineaPig2 = Fighter()
        if let fighterSpriteComponent = guineaPig2.component(ofType: SpriteComponent.self) {
            fighterSpriteComponent.node.position = CGPoint(x: 50, y: 50)
        }
        self.fighters.append(guineaPig2)
        //self.entityManager.add(entity: guineaPig2)
        
        // Temporarily
        Map1(withScene: self)

        self.configureStates()
        self.entityManager.add(entity: fighter)
        self.configureGesturePad(for: view)
        self.configureCamera()
        self.configurePhysics()
        self.suicideArea()
        
        MultiplayerService.shared.updateSceneDelegate = self
        otherPlayers = MultiplayerService.shared.allocPlayers(in: self)
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
        
    
        //Send Ping request
        if Int(currentTime) % 2 == 1 && canSendPing{
            let date = Int((Date().timeIntervalSince1970 * 1000))
            MultiplayerService.shared.ping(message: .sendPingRequest(senderTime: date), sendToHost: true)
            canSendPing = false
        }else if Int(currentTime) % 2 != 1{
            canSendPing = true
        }
    }
}

extension MyScene: GesturePadDelegate {
    func performActionForAnalogMoving(inAngle angle: CGFloat, withDirectionX dx: CGFloat, AndDirectionY dy: CGFloat) {
        
        var messageType: MessageType = .sendMoveRequest(dx: dx)
        //if player is host
        MultiplayerService.shared.hostAction(completion: {
            self.fighter.walk(inDirectionX: dx)
        }) { (hostID) in
            messageType = .sendMoveResponse(playerID: hostID, dx: dx)
        }
        
        let data = Message(messageType: messageType)
        MultiplayerService.shared.sendData(data: data, sendDataMode: .reliable)
    }
    
    func performActionForAnalogStopMoving() {
        //self.fighter.idle()
        
        guard let node = self.fighter.component(ofType: SpriteComponent.self)?.node else {return}
        var messageType: MessageType = .sendStopRequest(position: node.position)
        
        //if player is host
        MultiplayerService.shared.hostAction(completion: {
            self.fighter.idle()
            self.fighter.changePlayerPosition(position: node.position)
        }) { (hostID) in
            messageType = .sendStopResponse(playerID: hostID, position: node.position)
        }
        
        let data = Message(messageType: messageType)
        MultiplayerService.shared.sendData(data: data, sendDataMode: .reliable)
        
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

extension MyScene: UpdateSceneDelegate {
    func updatePlayerMove(dx: CGFloat, from playerID: Int) {
        
        let isSelf = GKLocalPlayer.local.playerID.toInt() == playerID
        
        if let otherPlayer = otherPlayers[playerID] {
            otherPlayer.walk(inDirectionX: dx)
        }else if isSelf{
            self.fighter.walk(inDirectionX: dx)
            print("error while getting player")
        }
    }
    
    func updatePlayerStopMove(playerPosition: CGPoint, from playerID: Int) {
        
    
        let isSelf = GKLocalPlayer.local.playerID.toInt() == playerID
        
        if let otherPlayer = otherPlayers[playerID] {
            otherPlayer.idle()
            otherPlayer.changePlayerPosition(position: playerPosition)
        }else if isSelf{
            self.fighter.idle()
            self.fighter.changePlayerPosition(position: playerPosition)
            print("error while getting player")
        }
        
    }
    
    func jumpPlayer(playerID: Int) {
        
    }
    
    func showPing(ping: Int, host: GKPlayer) {
        pingLabel.text = "ping: \(ping)ms, host player:\(host.alias)"
    }
    
}
