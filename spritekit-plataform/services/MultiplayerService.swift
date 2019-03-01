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
    
    func startingGame(){

        let randomNumber = allPlayers[selfPlayer.playerID]!
        let messageStart = Message(messageType: .startGame(randomNumber: randomNumber))
        sendData(data: messageStart, sendDataMode: .reliable)
    }
    
    //For each player in match, alloc in the scene
    func allocPlayers(in scene: MyScene) -> [Int: Fighter]{
        var otherPlayers : [Int: Fighter] = [:]
        if let match = GameCenterService.shared.currentMatch {
            //for each other player(except self), put in the scene
            match.players.forEach {
                let otherPlayer = Fighter(playerID: $0.playerID)
                
                if let node = otherPlayer.component(ofType: SpriteComponent.self)?.node {
                    node.position = CGPoint(x: 0, y: 0)
                }
                
                if let playerIDInt = $0.playerID.toInt() {
                    otherPlayers[playerIDInt] = otherPlayer
                    scene.entityManager.add(entity: otherPlayer)
                }
            }
        }
        return otherPlayers
        
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
    
    func hostAction(completion: @escaping ()-> Void, msg: (_ hostID: Int)-> Void){
        if  let host = hostPlayer,
            let hostID = host.playerID.toInt(),
            (host == selfPlayer) {
                let ping = Double(pingHost) / 1000
                Timer.scheduledTimer(withTimeInterval: ping, repeats: false) { (_) in
                    completion()
                }
            
                msg(hostID)
        }
    }
    
}

extension MultiplayerService: ReceiveDataDelegate {
    func didReceive(message: Message, from player: GKPlayer) {
        
        switch message.messageType {
        case .sendMoveRequest(let dx):
            
            if let host = hostPlayer, let playerIDInt = player.playerID.toInt(), host == GKLocalPlayer.local {
                updateSceneDelegate?.updatePlayerMove(dx: dx, from: playerIDInt)
            }
            
            if let playerID = player.playerID.toInt() {
                let data = Message(messageType: .sendMoveResponse(playerID: playerID, dx: dx))
                MultiplayerService.shared.sendData(data: data, sendDataMode: .unreliable)
            }
            
        case .sendMoveResponse(let playerID, let position):
            
            updateSceneDelegate?.updatePlayerMove(dx: position, from: playerID)
            
        case .sendStopRequest(let position):
            if let host = hostPlayer, let playerIDInt = player.playerID.toInt(), host == GKLocalPlayer.local {
                updateSceneDelegate?.updatePlayerStopMove(playerPosition: position, from: playerIDInt)
            }
            if let playerID = player.playerID.toInt() {
                let data = Message(messageType: .sendStopResponse(playerID: playerID, position: position))
                MultiplayerService.shared.sendData(data: data, sendDataMode: .unreliable)
                
            }
        case .sendStopResponse(let playerID, let position):
            
            updateSceneDelegate?.updatePlayerStopMove(playerPosition: position, from: playerID)
        
        case .sendJumpRequest:
            
            if let host = hostPlayer, let playerIDInt = player.playerID.toInt(), host == GKLocalPlayer.local {
                updateSceneDelegate?.jumpPlayer(playerID: playerIDInt)
            }
            
            if let playerID = player.playerID.toInt() {
                let data = Message(messageType: .sendJumpResponse(playerID: playerID))
                MultiplayerService.shared.sendData(data: data, sendDataMode: .unreliable)
                
            }
            
        case .sendJumpResponse(let playerID):
            updateSceneDelegate?.jumpPlayer(playerID: playerID)
            
            
        case .sendPingRequest(let senderTime):
            MultiplayerService.shared.responsePingRequest(senderTime: senderTime)
            
            //if player is the host, update the ping
            if let host = hostPlayer, (host == GKLocalPlayer.local) {
                updateSceneDelegate?.showPing(ping: self.pingHost, host: host)
            }
        case .sendPingResponse(let senderTime, let halfPing):
            let ping = MultiplayerService.shared.receivePing(senderTime: senderTime, halfPing: halfPing)
            guard let host = MultiplayerService.shared.hostPlayer else {return}
            updateSceneDelegate?.showPing(ping: ping, host: host)
            
        default:
            print("default")
        }
    }
    
    
    
}
