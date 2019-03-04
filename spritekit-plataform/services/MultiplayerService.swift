//
//  MultiplayerService.swift
//  spritekit-plataform
//
//  Created by João Paulo de Oliveira Sabino on 28/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import GameKit

class MultiplayerService: NSObject {
    
    static let shared = MultiplayerService()
    
    private(set) var matchMinPlayers : Int = 3
    private(set) var matchMaxPlayers : Int = 3
    private(set) var hostPlayer: GKPlayer?
    private(set) var pingHost: Int = 40 // in miliseconds
    private(set) var allPlayers: [String : Float] = [String : Float]()
    private(set) var selfPlayer = GKLocalPlayer.local
    var updateSceneDelegate: UpdateSceneDelegate?
    override init() {
        super.init()
        
        hostPlayer = GKLocalPlayer.local
        let randomNumber = GKRandomSource.sharedRandom().nextUniform()
        allPlayers[GKLocalPlayer.local.playerID] = randomNumber
        
        GameCenterService.shared.receiveDataDelegate = self
    }
    
    func sendData(data : Message, sendDataMode: GKMatch.SendDataMode){
        
        do {
            let d = data.archive()
            if let hostPlayer = MultiplayerService.shared.hostPlayer, GKLocalPlayer.local != hostPlayer {
                try GameCenterService.shared.currentMatch?.send(d, to: [hostPlayer], dataMode: sendDataMode)
            }else{
                try GameCenterService.shared.currentMatch?.sendData(toAllPlayers: d, with: sendDataMode)
            }
            
        } catch {
            print("error while archive data: \(error)")
        }
    }
    
    func sendActionMessage(clientMessage: MessageType, hostMessage: MessageType, hostAction: @escaping () -> Void){
        var messageType: MessageType = clientMessage
        
        if hostPlayer == selfPlayer {
            let ping = Double(pingHost) / 1000
            Timer.scheduledTimer(withTimeInterval: ping, repeats: false) { (_) in
                hostAction()
            }
            
            messageType = hostMessage
        }
        
        let data = Message(messageType: messageType)
        MultiplayerService.shared.sendData(data: data, sendDataMode: .reliable)
    }
    
    func startingGame(){

        let randomNumber = allPlayers[selfPlayer.playerID]!
        let messageStart = Message(messageType: .startGame(randomNumber: randomNumber))
        sendData(data: messageStart, sendDataMode: .reliable)
    }
    
    //For each player in match, alloc in the scene
    func allocPlayers(in scene: MyScene) -> [Int: Fighter]{
        var allPlayers : [Int: Fighter] = [:]
        if let match = GameCenterService.shared.currentMatch {
            //for each other player(except self), put in the scene
            match.players.forEach {
                let otherPlayer = Fighter(playerID: $0.playerID)
                otherPlayer.playerAlias = $0.alias
                if let node = otherPlayer.component(ofType: SpriteComponent.self)?.node {
                    //TODO: set randomly the start position of each player
                    node.position = CGPoint(x: 0, y: 0)
                }
                allPlayers[$0.playerID.toInt()] = otherPlayer
                scene.entityManager.add(entity: otherPlayer)
            }
            
            //put self in the dictionary
            let player = Fighter(playerID: GKLocalPlayer.local.playerID)
            player.playerAlias = GKLocalPlayer.local.alias
            allPlayers[GKLocalPlayer.local.playerID.toInt()] = player
            scene.entityManager.add(entity: player)
        }else{
            
            //for single player only(testing mode), will be deleted soon
            //ADD MOCK PLAYERS HERE
            
            let player = Fighter(playerID: GKLocalPlayer.local.playerID)
            allPlayers[GKLocalPlayer.local.playerID.toInt()] = player
            scene.entityManager.add(entity: player)
        }
        return allPlayers
        
    }
    
    func ping(message: MessageType, sendToHost: Bool){
        do {
            
            let pingMessage = Message(messageType: message)
            let data = pingMessage.archive()
            
            if sendToHost {
                if let hostPlayer = MultiplayerService.shared.hostPlayer, GKLocalPlayer.local != hostPlayer {
                    try GameCenterService.shared.currentMatch?.send(data, to: [hostPlayer], dataMode: .reliable)
                }
            }else{
                try GameCenterService.shared.currentMatch?.sendData(toAllPlayers: data, with: .reliable)
            }
            
            
        } catch {
            print("error while archive data: \(error)")
        }
    }
    
    func setHostPlayer(){
        
        guard let hostPlayerID = (allPlayers.sorted { $0.1 < $1.1 }).first?.key else {return}
        
        GKPlayer.loadPlayers(forIdentifiers: [hostPlayerID]) { (players, error) in
            self.hostPlayer = (players?.first)!
        }
        
    }
    
    func addPlayer(with id: String, randomNumber: Float){
        allPlayers[id] = randomNumber
    }
    
    func responsePingRequest(senderTime: Int){
        let currentTime = Int((Date().timeIntervalSince1970 * 1000))
        let halfPing = abs(currentTime - senderTime)
        self.pingHost = halfPing * 2
        ping(message: .sendPingResponse(senderTime: currentTime,halfPing: halfPing), sendToHost: false)
    }
    
    func receivePing(senderTime: Int, halfPing: Int) -> Int{
        if let host = hostPlayer, GKLocalPlayer.local != host {
            let currentTime = Int((Date().timeIntervalSince1970 * 1000))
            let ping = abs(currentTime - senderTime) + halfPing
            return ping
        }
        return 0
    }
    
    
}

extension MultiplayerService: ReceiveDataDelegate {
    func didReceive(message: Message, from player: GKPlayer) {
        guard let host = hostPlayer else { return }
        let playerIDInt = player.playerID.toInt()
        
        switch message.messageType {
        
        //MOVE PLAYER
        case .sendMoveRequest(let dx):
            
            if host == GKLocalPlayer.local {
                updateSceneDelegate?.updatePlayerMove(dx: dx, from: playerIDInt)
            }
            let data = Message(messageType: .sendMoveResponse(playerID: playerIDInt, dx: dx))
            MultiplayerService.shared.sendData(data: data, sendDataMode: .unreliable)
        
        case .sendMoveResponse(let playerID, let position):
            
            updateSceneDelegate?.updatePlayerMove(dx: position, from: playerID)
           
        //STOP PLAYER
        case .sendStopRequest(let position):
            
            if host == GKLocalPlayer.local {
                updateSceneDelegate?.updatePlayerStopMove(playerPosition: position, from: playerIDInt)
            }
            let data = Message(messageType: .sendStopResponse(playerID: playerIDInt, position: position))
            MultiplayerService.shared.sendData(data: data, sendDataMode: .unreliable)
        
        case .sendStopResponse(let playerID, let position):
            
            updateSceneDelegate?.updatePlayerStopMove(playerPosition: position, from: playerID)
        
        //JUMP
        case .sendJumpRequest:
            
            if host == GKLocalPlayer.local {
                updateSceneDelegate?.updateJumpPlayer(playerID: playerIDInt)
            }
            let data = Message(messageType: .sendJumpResponse(playerID: playerIDInt))
            MultiplayerService.shared.sendData(data: data, sendDataMode: .reliable)
        
        case .sendJumpResponse(let playerID):
            
            updateSceneDelegate?.updateJumpPlayer(playerID: playerID)
          
        //DOWN
        case .sendDownRequest:
           
            if host == GKLocalPlayer.local {
                updateSceneDelegate?.updateDownPlayer(playerID: playerIDInt)
            }
            let data = Message(messageType: .sendDownResponse(playerID: playerIDInt))
            MultiplayerService.shared.sendData(data: data, sendDataMode: .reliable)
        
        case .sendDownResponse(let playerID):
            
            updateSceneDelegate?.updateDownPlayer(playerID: playerID)
        
        case .sendAttackRequest:
            var hittedPlayersArray : [Int] = [-1, -1, -1, -1]
            if host == GKLocalPlayer.local {
                hittedPlayersArray = (updateSceneDelegate?.updateAttackPlayerRequest(attackerID: playerIDInt))!
                updateSceneDelegate?.updateAttackPlayerResponse(attackerID: playerIDInt, receivedAttackIDs: hittedPlayersArray)
            }
            var hittedPlayers = HittedPlayers()
            
            hittedPlayers.player1 = hittedPlayersArray[0]
            hittedPlayers.player2 = hittedPlayersArray[1]
            hittedPlayers.player3 = hittedPlayersArray[2]
            hittedPlayers.player4 = hittedPlayersArray[3]
            
            let data = Message(messageType: .sendAttackResponse(attackerID: playerIDInt, receivedAtackIDs: hittedPlayers))
            MultiplayerService.shared.sendData(data: data, sendDataMode: .reliable)

            
        
        case .sendAttackResponse(let attackerID, let receivedAtackIDs):
            var arrayHitted : [Int] = []
            
            arrayHitted.append(receivedAtackIDs.player1)
            arrayHitted.append(receivedAtackIDs.player2)
            arrayHitted.append(receivedAtackIDs.player3)
            arrayHitted.append(receivedAtackIDs.player4)
    
            updateSceneDelegate?.updateAttackPlayerResponse(attackerID: attackerID, receivedAttackIDs: arrayHitted)
            
            
        //PING
        case .sendPingRequest(let senderTime):
            responsePingRequest(senderTime: senderTime)
            
            //if player is the host, update the ping without need to send to client
            if host == GKLocalPlayer.local {
                updateSceneDelegate?.showPing(ping: self.pingHost, host: host)
            }
            
        case .sendPingResponse(let senderTime, let halfPing):
            let ping = receivePing(senderTime: senderTime, halfPing: halfPing)
            updateSceneDelegate?.showPing(ping: ping, host: host)
            
        default:
            print("default")
        }
    }
    
    
    
}
