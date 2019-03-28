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
    
    case sendPositionRequest(position: CGPoint, state: State, directionDx: Int)
    case sendPositionResponse(playerID: Int, position: CGPoint, state: State, directionDx: Int)
    
    case sendStopRequest(position: CGPoint)
    case sendStopResponse(playerID: Int, position: CGPoint)
    
    case sendJumpRequest
    case sendJumpResponse(playerID: Int)
    
    case sendDownRequest
    case sendDownResponse(playerID: Int)
    
    case sendAttackRequest(state: State)
    case sendAttackResponse(attackerID: Int, receivedAtackIDs: HittedPlayers, state: State)
    
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
    var player1: Int = -1
    var player2: Int = -1
    var player3: Int = -1
    var player4: Int = -1
}

enum State: Int {
    case walk = 0
    case jump = 1
    case idle = 2
    case fall = 3
    case attack1 = 4
    case attack2 = 5
    case attack3 = 6

}
