//
//  ReceiveDataDelegate.swift
//  spritekit-plataform
//
//  Created by João Paulo de Oliveira Sabino on 28/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import GameKit

protocol ReceiveDataDelegate {
    func didReceive(message: Message, from player: GKPlayer)
    
}

protocol UpdateSceneDelegate {
    func updatePlayerMove(dx: CGFloat, from playerID: Int)
    func updatePlayerPosition(playerPosition: CGPoint, from playerID: Int, state: State, directionDx: Int, senderTime: Int)
    func updatePlayerStopMove(playerPosition: CGPoint, from playerID: Int)
    func updateJumpPlayer(playerID: Int)
    func updateDownPlayer(playerID: Int)
    func updateAttackPlayerRequest(attackerID: Int) -> [Int]
    func updateAttackPlayerResponse(attackerID: Int, receivedAttackIDs: [Int], state: State)
    func showPing(ping: Int, host: GKPlayer)
}


extension String {
    func toInt() -> Int{
        if let intValue = Int(self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
            return intValue
        }
        return 0
    }
}
