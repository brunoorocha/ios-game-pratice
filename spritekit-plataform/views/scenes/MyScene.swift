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
    
    var allPlayers : [Int: Fighter] = [:]
    var pingLabel: SKLabelNode!
    var canSendPing = true
    
    let multiplayerService = MultiplayerService.shared
    let selfPlayerID = GKLocalPlayer.local.playerID.toInt()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.white
        self.entityManager = EntityManager(withScene: self)
        
//        self.fighter = Fighter()
//        if let fighterSpriteComponent = self.fighter.component(ofType: SpriteComponent.self) {
//            fighterSpriteComponent.node.position = CGPoint(x: 0, y: 0)
//        }
//        self.fighters.append(fighter)
        
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
        self.configureGesturePad(for: view)
        self.configureCamera()
        self.configurePhysics()
        self.suicideArea()
        
        allPlayers = MultiplayerService.shared.allocPlayers(in: self)
        if let player = allPlayers[GKLocalPlayer.local.playerID.toInt()] {
            self.fighter = player
        }
        
        MultiplayerService.shared.updateSceneDelegate = self
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
    
        self.allPlayers.forEach { (_,value) in
            value.update(deltaTime: currentTime)
        }
        
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
        
        let clientMessage: MessageType = .sendMoveRequest(dx: dx)
        let hostMessage: MessageType = .sendMoveResponse(playerID: selfPlayerID, dx: dx)
        
        multiplayerService.sendActionMessage(clientMessage: clientMessage, hostMessage: hostMessage) {
            self.fighter.walk(inDirectionX: dx)
        }
        
    }
    
    func performActionForAnalogStopMoving() {

        guard let playerNode = self.fighter.component(ofType: SpriteComponent.self)?.node else {return}
        
        let clientMessage: MessageType = .sendStopRequest(position: playerNode.position)
        let hostMessage: MessageType = .sendStopResponse(playerID: selfPlayerID, position: playerNode.position)
        
        let playerPosition = playerNode.position
        
        multiplayerService.sendActionMessage(clientMessage: clientMessage, hostMessage: hostMessage) {
            self.fighter.idle()
            self.fighter.changePlayerPosition(position: playerPosition)
        }
        
    }
    
    func performActionForTap() {
        let hittedPlayers = self.fighter.attack()
        var hitted = HittedPlayers()
        
        hitted.player1 = hittedPlayers[0]
        hitted.player2 = hittedPlayers[1]
        hitted.player3 = hittedPlayers[2]
        hitted.player4 = hittedPlayers[3]
        
        let clientMessage: MessageType = .sendAttackRequest
        let hostMessage: MessageType = .sendAttackResponse(attackerID: selfPlayerID, receivedAtackIDs: hitted)
        
        multiplayerService.sendActionMessage(clientMessage: clientMessage, hostMessage: hostMessage) {
            
            hittedPlayers.forEach { (playerID) in
                if let hittedPlayer = self.allPlayers[playerID] {
                    hittedPlayer.receiveDamage(damage: self.fighter.damage)
                }
            }
        }

        
        
        
    }
    
    func performActionForSwipeUp() {
        
        let clientMessage: MessageType = .sendJumpRequest
        let hostMessage: MessageType = .sendJumpResponse(playerID: selfPlayerID)
        
        multiplayerService.sendActionMessage(clientMessage: clientMessage, hostMessage: hostMessage) {
            self.fighter.jump()
        }
        
    }
    
    func performActionForSwipeDown() {
    
        let clientMessage: MessageType = .sendDownRequest
        let hostMessage: MessageType = .sendDownResponse(playerID: selfPlayerID)
        
        multiplayerService.sendActionMessage(clientMessage: clientMessage, hostMessage: hostMessage) {
            self.fighter.down()
        }
        
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
        if let player = allPlayers[playerID] {
            player.walk(inDirectionX: dx)
        }
    }
    
    func updatePlayerStopMove(playerPosition: CGPoint, from playerID: Int) {
        if let player = allPlayers[playerID] {
            player.idle()
            player.changePlayerPosition(position: playerPosition)
        }
    }
    
    func updateJumpPlayer(playerID: Int) {
        if let player = allPlayers[playerID] {
            player.jump()
        }
    }
    
    func updateDownPlayer(playerID: Int) {
        if let player = allPlayers[playerID] {
            player.down()
        }
    }
    
    func updateAttackPlayerRequest(attackerID: Int) -> [Int] {
        if let player = allPlayers[attackerID] {
            return player.attack()
        }
        
        return []
    }
    
    func updateAttackPlayerResponse(attackerID: Int, receivedAttackIDs: [Int]) {
        guard let attackerPlayer = allPlayers[attackerID] else {return}
        
        attackerPlayer.attack()
        
        receivedAttackIDs.forEach { (playerID) in
            if let hittedPlayer = allPlayers[playerID] {
                hittedPlayer.receiveDamage(damage: attackerPlayer.damage)
            }
        }
        
        
    }
    
    func showPing(ping: Int, host: GKPlayer) {
        pingLabel.text = "ping: \(ping)ms, host player:\(host.alias)"
    }
    
}
