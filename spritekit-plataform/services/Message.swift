//
//  Message.swift
//  spritekit-plataform
//
//  Created by João Paulo de Oliveira Sabino on 28/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import GameKit

enum MessageType {
    case sendMoveRequest(dx: CGFloat)
    case sendMoveResponse(playerID: Int, dx: CGFloat)
    
    case sendPositionRequest(position: CGPoint)
    case sendPositionResponse(playerID: Int, position: CGPoint)
    
    case sendStopRequest(position: CGPoint)
    case sendStopResponse(playerID: Int, position: CGPoint)
    
    case sendJumpRequest
    case sendJumpResponse(playerID: Int)
    
    case sendDownRequest
    case sendDownResponse(playerID: Int)
    
    case sendAttackRequest
    case sendAttackResponse(attackerID: Int, receivedAtackIDs: HittedPlayers)
    
    case startGame(randomNumber: Float)
    
    case sendPingRequest(senderTime: Int)
    case sendPingResponse(senderTime: Int, halfPing: Int)
}

struct Message {
    var messageType: MessageType
    init(messageType: MessageType){
        self.messageType = messageType
    }
    
    //Struct to data
    func archive() -> Data{
        var d = self
        return Data(bytes: &d, count: MemoryLayout.stride(ofValue: d))
    }
    
    //Data to struct
    static func unarchive(_ d: Data) -> Message?{
        guard d.count == MemoryLayout<Message>.stride else {
            fatalError("Error!")
        }
        
        var message: Message?
        
        d.withUnsafeBytes({(bytes: UnsafePointer<Message>) -> Void in
            message = UnsafePointer<Message>(bytes).pointee
        })
        return message
    }
    
}

struct HittedPlayers{
    var player1: Int = 0
    var player2: Int = 0
    var player3: Int = 0
    var player4: Int = 0
}
