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
    let multiplayerService = MultiplayerService.shared
    let selfPlayerID = GKLocalPlayer.local.playerID.toInt()
    var lookingLeft = true
    var nodePosition = CGPoint.zero
    var inputController: InputController!
    
    var isControlsVisible: Bool = PlayerDefaults.isControlsVisible
    var isSoundEnabled: Bool = PlayerDefaults.isSoundEnabled
    var isWatchingMode = false
    
    var map: Map1!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.backgroundColor = UIColor.white
        self.entityManager = EntityManager(withScene: self)
        self.configureCamera()
        self.configureStates()
        //self.configureUI()
        self.configurePhysics()
        self.suicideArea()
        self.showBackButton()
        
        if (isControlsVisible) {
            self.setupJoystick()
        }
        else {
            self.configureGesturePad(for: view)
        }
        
        // Sounds
        SoundManager.shared().removeFromParent()
        SoundManager.shared().isMutedAction = !self.isSoundEnabled
        SoundManager.shared().isMutedMusic = !self.isSoundEnabled
        self.addChild(SoundManager.shared())
        
        // Temporarily
        let arena = PListManager.loadArena(with: "FighterArena")
        self.map = Map1(withScene: self, andArena: arena)
        
        allPlayers = MultiplayerService.shared.allocPlayers(in: self)
        if let player = allPlayers[GKLocalPlayer.local.playerID.toInt()] {
            self.fighter = player
            
        }
        if let node = self.fighter.component(ofType: SpriteComponent.self)?.node {
            self.playerNode = node
        }
        
        if let nodeCopy = self.fighterCopy.component(ofType: SpriteComponent.self)?.node  {
            nodeCopy.alpha = 0.01;
            self.playerNodeCopy = nodeCopy
        }
        
        MultiplayerService.shared.updateSceneDelegate = self
        
    }
    
    func configureStates() {
        let prepareState = PrepareFightState(withScene: self)
        let fightingState = FightingState(withScene: self)
        let pausedState = PausedState(withScene: self)
        let loseState = LoseState(withScene: self)
        let watchingState = WatchingState(withScene: self)
        let endState = EndState(withScene: self)
        self.stateMachine = GKStateMachine(states: [prepareState, fightingState, pausedState, loseState, watchingState, endState])
        
        self.stateMachine.enter(PrepareFightState.self)
        //self.stateMachine.enter(FightingState.self)
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
        let area = SKSpriteNode(color: .red, size: CGSize(width: width, height: 10))
        area.position = CGPoint(x: 0, y: -self.size.height/2 - 20)
        area.physicsBody = SKPhysicsBody(rectangleOf: area.size)
        area.physicsBody?.categoryBitMask = CategoryMask.suicideArea
        area.physicsBody?.contactTestBitMask = CategoryMask.player
        area.physicsBody?.collisionBitMask = CategoryMask.none
        area.physicsBody?.usesPreciseCollisionDetection = true
        area.physicsBody?.affectedByGravity = false
        area.physicsBody?.allowsRotation = false
        area.physicsBody?.restitution = 0
        area.physicsBody?.friction = 0
        area.zPosition = 40
        area.alpha = 0.01
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
            //cam.addChild(debugLabel)


        }
    }
    
    func configureGesturePad(for view: SKView) {
        guard let view = self.view else { return }
        self.gesturePad = GesturePad(forView: view)
        self.gesturePad.delegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        self.allPlayers.forEach { (key,value) in
            value.update(deltaTime: currentTime)
        }
        
        self.fighterCopy.update(deltaTime: currentTime)
        
        if (!self.isWatchingMode) {
            guard let node = self.fighter.component(ofType: SpriteComponent.self)?.node else {return}
            let move = SKAction.move(to: node.position, duration: 0.3)
            self.camera?.run(move)
            
            
        }else{
            if let controller = inputController {
                controller.alpha = 0.01
            }
        }
        
        
        //Send Ping request every frame
        let date = Int((Date().timeIntervalSince1970 * 1000))
        MultiplayerService.shared.ping(message: .sendPingRequest(senderTime: date), sendToHost: true)

        
        guard let nodeCopy = self.fighterCopy.component(ofType: SpriteComponent.self)?.node else {return}
        let distance = hypot(nodeCopy.position.x - nodePosition.x,
                             nodeCopy.position.y - nodePosition.y)
        
        
        
        if distance > 0 {
            self.copyStatesAndSend()
        }
        
        nodePosition = nodeCopy.position
        self.map.updateParallaxBackground()

//        self.allPlayers.forEach { (i,fighter) in
//            print("\(fighter.playerAlias) kills: \(fighter.countKills)")
//        }
        
    }
    
    func copyStatesAndSend() {
        let directionDx = Int(playerNodeCopy.xScale)
        let currentState = self.fighterCopy.getCurrentStateEnum()
        let currentPosition = self.playerNodeCopy.position
        let currentTime = Int((Date().timeIntervalSince1970 * 1000))
        let clientMessage: MessageType = .sendPositionRequest(position: currentPosition, state: currentState, directionDx: directionDx, senderTime: currentTime)
        
        let hostMessage: MessageType = .sendPositionResponse(playerID: selfPlayerID, position: currentPosition, state: currentState, directionDx: directionDx, senderTime: currentTime)
        
        let copy = self.fighterCopy.copy() as! Fighter
        let originalState = self.fighter.stateMachine.currentState
        
        multiplayerService.sendActionMessage(isMoving: true, clientMessage: clientMessage, hostMessage: hostMessage, sendDataMode: .unreliable) {
            
            self.fighter.changePlayerPosition(position: currentPosition)
            self.fighter.repeatCopyMove(originalState: originalState, copy: copy)
        }
    }
    
    func attackTap() {
        if self.fighter.health <= 0 {return}
        let hittedPlayersArray = self.fighterCopy.attack(playAnim: true)
        var hittedPlayers = HittedPlayers()
        
        hittedPlayers.player1 = hittedPlayersArray[0]
        hittedPlayers.player2 = hittedPlayersArray[1]
        hittedPlayers.player3 = hittedPlayersArray[2]
        hittedPlayers.player4 = hittedPlayersArray[3]
        
        //let is3rdAttack = (self.fighterCopy.stateMachine.currentState is FighterAttack3State)
        let currentState = self.fighterCopy.getCurrentStateEnum()
        
        let clientMessage: MessageType = .sendAttackRequest(state: currentState)
        let hostMessage: MessageType = .sendAttackResponse(attackerID: selfPlayerID, receivedAtackIDs: hittedPlayers, state: currentState)
        
        multiplayerService.sendActionMessage(isMoving: false, clientMessage: clientMessage, hostMessage: hostMessage, sendDataMode: .reliable) {
            hittedPlayersArray.forEach { (playerID) in
                let _ = self.fighter.attack(playAnim: true)
                if let hittedPlayer = self.allPlayers[playerID] {
                    hittedPlayer.receiveDamage(damage: self.fighter.damage)
                    if hittedPlayer.health <= 0 {
                        self.fighter.countKills += 1
                        let _ = self.checkForWinner()
                    }
                }
            }
        }
    }
    
    func checkForWinner() -> Bool {
        var playersLive: Int = 0
        var winnerPlayer: Fighter?
        self.allPlayers.forEach { (i,fighter) in
            if fighter.health > 0 {
                winnerPlayer = fighter
                playersLive += 1
            }
        }
        print("playerLive: \(playersLive)")
        if playersLive == 1, let winner = winnerPlayer  {
            print("winner: \(winner.playerAlias)")
            self.stateMachine.state(forClass: EndState.self)?.winnerAlias = winner.playerAlias
            self.stateMachine.enter(EndState.self)
            return true
        }
        
        return false
    }
    
    func showBackButton() {
        guard let camera = self.camera, let view = self.view else { return }
        let sceneTop = self.size.height / 2
        let sceneRight = self.size.width / 2
        let topOverlay = SKSpriteNode(texture: SKTexture(imageNamed: "gradient-overlay"), size: CGSize(width: view.frame.size.width, height: 52.0))
        topOverlay.position.y = sceneTop - (topOverlay.size.height / 2)
        topOverlay.zPosition = 11
        
        let menuButton = ButtonNode.makeButton(withText: "MENU", andSize: CGSize(width: 56, height: 32))
        menuButton.position.x = sceneRight - (menuButton.size.width / 2) - 16
        menuButton.zPosition = 6
        menuButton.actionBlock = {
            self.stateMachine.enter(PausedState.self)
        }
        
        topOverlay.addChild(menuButton)
        camera.addChild(topOverlay)
    }

}

extension MyScene: GesturePadDelegate {
    func performActionForAnalogMoving(inAngle angle: CGFloat, withDirectionX dx: CGFloat, AndDirectionY dy: CGFloat) {
        self.fighterCopy.walk(inDirectionX: dx)
    }
    
    func performActionForAnalogStopMoving() {
        self.fighterCopy.idle()
    }
    
    func performActionForTap() {
        self.attackTap()
    }
    
    func performActionForSwipeUp() {
        self.fighterCopy.jump()
    }
    
    func performActionForSwipeDown() {
        self.fighterCopy.down()
    }
}

extension MyScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if ( collision == CategoryMask.player | CategoryMask.suicideArea ) {
            if let killer = self.fighter.lastAttackPlayer {
                self.stateMachine.state(forClass: LoseState.self)?.killerAlias = killer.playerAlias
            }
            
            print("Commited suicide")
            let playerNode = contact.bodyA.categoryBitMask == CategoryMask.player ? contact.bodyA.node : contact.bodyB.node
            
            
            self.allPlayers.forEach { (i,fighter) in
                if let node = fighter.component(ofType: SpriteComponent.self)?.node, node == playerNode {
                    
                    fighter.suicide()
                    
                    if !self.checkForWinner() && fighter.playerID == GKLocalPlayer.local.playerID {
                        self.stateMachine.enter(LoseState.self)
                    }
                }
            }

            let _ = checkForWinner()
        }
    }
}

extension MyScene: UpdateSceneDelegate {
    func updatePlayerMove(dx: CGFloat, from playerID: Int) {
        if let player = allPlayers[playerID] {
            player.walk(inDirectionX: dx)
        }
    }
    func updatePlayerPosition(playerPosition: CGPoint, from playerID: Int, state: State, directionDx: Int, senderTime: Int) {
        if let player = allPlayers[playerID] {
            if player.playerID != GKLocalPlayer.local.playerID {
                player.changePlayerPosition(position: playerPosition)
                player.changePlayerState(state: state, inDirectionX: directionDx)
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
        if let player = allPlayers[attackerID], player.health > 0 {
            return player.attack(playAnim: false)
        }
        
        return [-1,-1,-1,-1]
    }
    
    func updateAttackPlayerResponse(attackerID: Int, receivedAttackIDs: [Int], state: State) {
        guard let attackerPlayer = allPlayers[attackerID] else {return}
        
        let _ = attackerPlayer.attack(playAnim: true)
        
        //attackerPlayer.changePlayerState(state: state, inDirectionX: 1)
        
        receivedAttackIDs.forEach { (playerID) in
            if let hittedPlayer = allPlayers[playerID] {
                hittedPlayer.receiveDamage(damage: attackerPlayer.damage)
                
                if hittedPlayer.health <= 0 && hittedPlayer.playerID == GKLocalPlayer.local.playerID {
                    if let hittedNodeCopy = self.fighterCopy.component(ofType: SpriteComponent.self)?.node {
                        self.run(SKAction.wait(forDuration: 1)) {
                            hittedNodeCopy.removeFromParent()
                        }
                    }
                    attackerPlayer.countKills += 1
                    
                    if let killer = hittedPlayer.lastAttackPlayer {
                        self.stateMachine.state(forClass: LoseState.self)?.killerAlias = killer.playerAlias
                    }
                    
                    if !self.checkForWinner() {
                        self.stateMachine.enter(LoseState.self)
                    }
                    
                }
        
                let _ = self.checkForWinner()
                
                if hittedPlayer.playerID == GKLocalPlayer.local.playerID && state == .attack3 {
                    guard let attacker = self.allPlayers[attackerID] else {return}
                    self.fighterCopy.reiceivePushDamage(force: attacker.forcePush, direction: attacker.fighterDirection)
                }
            }
        }
    
    }
    
    func showPing(ping: Int, host: GKPlayer) {
        
        //update Ping every second
//        let currentDate = Int((Date().timeIntervalSince1970))
//        if currentDate % 2 == 1 && canSendPing {
//            pingLabel.text = "ping: \(ping)ms, host player:\(host.alias)"
//            canSendPing = false
//        }else if currentDate % 2 != 1{
//            canSendPing = true
//        }

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
        self.attackTap()
    }
    
    func joystickDidTapButtonB() {
        self.fighterCopy.jump()
    }
    
    func joystickDidTapDown() {
        self.fighterCopy.down()

    }
    
}

extension MyScene: PlayerConnectedDelegate {
    func didPlayerConnected() {
        self.allPlayers.forEach { (i,fighter) in
            if let node = fighter.component(ofType: SpriteComponent.self)?.node {
                node.removeFromParent()
            }
        }
        
        self.playerNodeCopy.removeFromParent()
        self.playerNode.removeFromParent()
        
        self.allPlayers = MultiplayerService.shared.allocPlayers(in: self)
        
        if let player = allPlayers[GKLocalPlayer.local.playerID.toInt()] {
            self.fighter = player
        }
        if let node = self.fighter.component(ofType: SpriteComponent.self)?.node {
            self.playerNode = node
        }
        
        if let nodeCopy = self.fighterCopy.component(ofType: SpriteComponent.self)?.node  {
            nodeCopy.alpha = 0.01;
            self.playerNodeCopy = nodeCopy
        }
    }
}
