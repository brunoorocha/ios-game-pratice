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
    var fighterCopy: Fighter!
    var playerNode: SKSpriteNode!
    var playerNodeCopy: SKSpriteNode!
    var entityManager: EntityManager!
    var stateMachine: GKStateMachine!
    var fighters : [Fighter] = []
    
    var allPlayers : [Int: Fighter] = [:]
    var pingLabel: SKLabelNode!
    var debugLabel: SKLabelNode!
    var canSendPing = true
    var previousPosition: CGPoint = CGPoint.zero;
    let multiplayerService = MultiplayerService.shared
    let selfPlayerID = GKLocalPlayer.local.playerID.toInt()
    var lookingLeft = true

    var inputController: InputController!

    var map: Map1!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.white
        self.entityManager = EntityManager(withScene: self)                
        self.configureStates()
        self.configureGesturePad(for: view)
        self.configureCamera()
        self.configureUI()
        self.configurePhysics()
        self.suicideArea()
        
        // Temporarily
		    let arena = PListManager.loadArena(with: "FighterArena")
        self.map = Map1(withScene: self, andArena: arena)
        
        allPlayers = MultiplayerService.shared.allocPlayers(in: self)
        if let player = allPlayers[GKLocalPlayer.local.playerID.toInt()] {
            self.fighter = player
            
        }
        if let node = self.fighter.component(ofType: SpriteComponent.self)?.node {
            previousPosition = node.position
            self.playerNode = node
        }
        
        if let nodeCopy = self.fighterCopy.component(ofType: SpriteComponent.self)?.node  {
            nodeCopy.alpha = 0.01;
            self.playerNodeCopy = nodeCopy
        }
        
        MultiplayerService.shared.updateSceneDelegate = self
        
        self.setupJoystick()
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
    
    func setupJoystick(){
        let inputSize = CGSize(width: self.size.width, height: self.size.height)
        inputController = InputController(size: inputSize)
        inputController.zPosition = 10
        inputController.position = self.position
        inputController.joystickDelegate = self
        
        if let cam = self.camera {
            cam.addChild(inputController)
        }
        
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
    
    func configureUI(){
        
        if let cam = self.camera {
            
            //ping label
            pingLabel = SKLabelNode(text: "ping: 0 ms, host: \(MultiplayerService.shared.selfPlayer.alias)")
            pingLabel.position = CGPoint(x: self.size.width/2 - 20  , y: self.size.height/2 - 40)
            pingLabel.horizontalAlignmentMode = .right
            pingLabel.fontName = "Helvetica"
            pingLabel.fontColor = SKColor.black
            pingLabel.fontSize = 18
            pingLabel.zPosition = 10
            cam.addChild(pingLabel)
            
            //debug label
            debugLabel = SKLabelNode(text: "debug label")
            debugLabel.position = CGPoint(x: -self.size.width/2 + 20  , y: self.size.height/2 - 40)
            debugLabel.horizontalAlignmentMode = .left
            debugLabel.fontName = "Helvetica"
            debugLabel.fontColor = SKColor.black
            debugLabel.fontSize = 18
            debugLabel.zPosition = 2
            cam.addChild(debugLabel)
            
            
        }
    }
    
    func configureGesturePad(for view: SKView) {
        //self.gesturePad = GesturePad(forView: view)
        //self.gesturePad.delegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        
        self.allPlayers.forEach { (key,value) in
            value.update(deltaTime: currentTime)
        }
        self.fighterCopy.update(deltaTime: currentTime)
        
        var fighters: [Fighter] = []
        for (i, fighter) in self.allPlayers.enumerated() {
            fighters.append(fighter.value)
        }
        
        debugLabel.text = "1: \(fighters[0].health), 2: \(fighters[1].health)"
        
        guard let node = self.fighter.component(ofType: SpriteComponent.self)?.node else {return}
            let move = SKAction.move(to: node.position, duration: 0.3)
            self.camera?.run(move)
        
        
        //Send Ping request
        if Int(currentTime) % 2 == 1 && canSendPing{
            let date = Int((Date().timeIntervalSince1970 * 1000))
            MultiplayerService.shared.ping(message: .sendPingRequest(senderTime: date), sendToHost: true)
            canSendPing = false
        }else if Int(currentTime) % 2 != 1{
            canSendPing = true
        }
        

        let distance = hypot(playerNodeCopy.position.x - previousPosition.x,
                             playerNodeCopy.position.y - previousPosition.y)
        
        if distance > 0 {
            let directionDx = Int(playerNodeCopy.xScale)
            
            let currentState = self.fighterCopy.getCurrentStateEnum()
        
            let clientMessage: MessageType = .sendPositionRequest(position: playerNodeCopy.position, state: currentState, directionDx: directionDx)
            
            let hostMessage: MessageType = .sendPositionResponse(playerID: selfPlayerID, position: playerNodeCopy.position, state: currentState, directionDx: directionDx)
            
            multiplayerService.sendActionMessage(clientMessage: clientMessage, hostMessage: hostMessage, sendDataMode: .unreliable) {
                self.fighter.changePlayerPosition(position: self.playerNodeCopy.position)
                self.fighter.repeatCopyMove(copy: self.fighterCopy)
            }
        }
        
        self.previousPosition = self.playerNodeCopy.position

        self.map.updateParallaxBackground()

    }

}

extension MyScene: GesturePadDelegate {
    func performActionForAnalogMoving(inAngle angle: CGFloat, withDirectionX dx: CGFloat, AndDirectionY dy: CGFloat) {
        //self.fighterCopy.walk(inDirectionX: dx)
        
    }
    
    func performActionForAnalogStopMoving() {
        //self.fighterCopy.idle()
    }
    
    func performActionForTap() {
//        let hittedPlayersArray = self.fighter.attack()
//        var hitted = HittedPlayers()
//        hitted.player1 = hittedPlayersArray[0]
//        hitted.player2 = hittedPlayersArray[1]
//        hitted.player3 = hittedPlayersArray[2]
//        hitted.player4 = hittedPlayersArray[3]
//
//        let clientMessage: MessageType = .sendAttackRequest
//        let hostMessage: MessageType = .sendAttackResponse(attackerID: selfPlayerID, receivedAtackIDs: hitted)
//
//        multiplayerService.sendActionMessage(clientMessage: clientMessage, hostMessage: hostMessage, sendDataMode: .reliable) {
//
//            hittedPlayersArray.forEach { (playerID) in
//                if let hittedPlayer = self.allPlayers[playerID] {
//                    hittedPlayer.receiveDamage(damage: self.fighter.damage)
//                    if let attacker = self.allPlayers[self.selfPlayerID]{
//                        if attacker.stateMachine.currentState is FighterAttack3State{
//                            //hittedPlayer.reiceivePushDamage(force: attacker.forcePush, direction: attacker.fighterDirection)
//                        }
//                    }
//                }
//            }
//        }

    }
    
    func performActionForSwipeUp() {
        //self.fighterCopy.jump()
    }
    
    func performActionForSwipeDown() {
        //self.fighterCopy.down()
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
    func updatePlayerPosition(playerPosition: CGPoint, from playerID: Int, state: State, directionDx: Int) {
        if let player = allPlayers[playerID] {
            player.changePlayerPosition(position: playerPosition)
            
            player.changePlayerState(state: state, inDirectionX: directionDx)
            
            if playerID == GKLocalPlayer.local.playerID.toInt() {
                //player.repeatCopyMove(copy: self.fighterCopy)
            }
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
        
        return [-1,-1,-1,-1]
    }
    
    func updateAttackPlayerResponse(attackerID: Int, receivedAttackIDs: [Int]) {
        guard let attackerPlayer = allPlayers[attackerID] else {return}
        
        
        let _ = attackerPlayer.attack()
        
        receivedAttackIDs.forEach { (playerID) in
            if let hittedPlayer = allPlayers[playerID] {
                hittedPlayer.receiveDamage(damage: attackerPlayer.damage)
                if let attacker = self.allPlayers[self.selfPlayerID]{
                    if attacker.stateMachine.currentState is FighterAttack3State{
                        hittedPlayer.reiceivePushDamage(force: attacker.forcePush, direction: attacker.fighterDirection)
                    }
                }
            }
        }
        
        
    }
    
    func showPing(ping: Int, host: GKPlayer) {
        pingLabel.text = "ping: \(ping)ms, host player:\(host.alias)"
    }
    
}

extension MyScene: JoystickDelegate {
    
    func joystickDidStartTracking() {
        
    }
    
    func joystickDidMoved(direction: CGPoint) {
        self.fighterCopy.walk(inDirectionX: direction.x)
    }
    
    func joystickUpdateTracking(direction: CGPoint) {
        
    }
    
    func joystickDidEndTracking(direction: CGPoint) {
        self.fighterCopy.idle()
    }
    
    func joystickDidTapButtonA() {
        let hittedPlayersArray = self.fighter.attack()
        var hitted = HittedPlayers()
        hitted.player1 = hittedPlayersArray[0]
        hitted.player2 = hittedPlayersArray[1]
        hitted.player3 = hittedPlayersArray[2]
        hitted.player4 = hittedPlayersArray[3]

        let clientMessage: MessageType = .sendAttackRequest
        let hostMessage: MessageType = .sendAttackResponse(attackerID: selfPlayerID, receivedAtackIDs: hitted)

        multiplayerService.sendActionMessage(clientMessage: clientMessage, hostMessage: hostMessage, sendDataMode: .reliable) {

            hittedPlayersArray.forEach { (playerID) in
                if let hittedPlayer = self.allPlayers[playerID] {
                    hittedPlayer.receiveDamage(damage: self.fighter.damage)
                    if let attacker = self.allPlayers[self.selfPlayerID]{
                        if attacker.stateMachine.currentState is FighterAttack3State{
                            //hittedPlayer.reiceivePushDamage(force: attacker.forcePush, direction: attacker.fighterDirection)
                        }
                    }
                }
            }
        }
    }
    
    func joystickDidTapButtonB() {
        self.fighterCopy.jump()
    }
    
    func joystickDidTapDown() {
        self.fighterCopy.down()
    }
    
}
