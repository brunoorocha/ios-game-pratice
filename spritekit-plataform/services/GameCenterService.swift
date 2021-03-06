//
//  GameCenterService.swift
//  spritekit-plataform
//
//  Created by João Paulo de Oliveira Sabino on 28/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import GameKit

class GameCenterService: NSObject {
    static let shared = GameCenterService()
    
    var authenticationViewController: UIViewController?
    var currentMatch: GKMatch?
    var currentMatchmakerVC: GKMatchmakerViewController?
    var playerConnectedDelegate : PlayerConnectedDelegate?
    
    var receiveDataDelegate: ReceiveDataDelegate?
    static var isAuthenticated : Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { authenticationVC, error in
            
            NotificationCenter.default.post(name: .authenticationChanged , object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)
                print("Authenticated to Game Center!")
                
            }
            else if let vc = authenticationVC {
                self.authenticationViewController?.present(vc,animated: true)
            }
            else{
                print("Error authentication to GameCenter: \(error?.localizedDescription ?? "none")")
            }
            
        }
        
    }
    
    func presentMatchMaker(){
        guard GKLocalPlayer.local.isAuthenticated else {
            return
        }
        
        let request = GKMatchRequest()
        
        request.minPlayers = MultiplayerService.shared.matchMinPlayers
        request.maxPlayers = MultiplayerService.shared.matchMaxPlayers
        request.defaultNumberOfPlayers = MultiplayerService.shared.defaultNumberOfPlayers
        
        request.inviteMessage = "Would you like to play?"
        
        if let vc = GKMatchmakerViewController(matchRequest: request) {

            vc.matchmakerDelegate = self
            currentMatchmakerVC = vc
            authenticationViewController?.present(vc, animated: true)
        }
    }
}

extension GameCenterService : GKMatchmakerViewControllerDelegate {
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker did fail with error: \(error.localizedDescription).")
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        self.currentMatch = match
        match.delegate = self
        
        MultiplayerService.shared.setRandomNumber()
        MultiplayerService.shared.startingGame()
        
        NotificationCenter.default.post(name: .presentGame, object: match)
        if let vc = currentMatchmakerVC {
            currentMatchmakerVC = nil
            vc.dismiss(animated: true)
        }
        
    }
    
}

extension GameCenterService: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        
        if let d = Message.unarchive(data) {
            receiveDataDelegate?.didReceive(message: d, from: player)
            
            if case .startGame(let randomNumber) = d.messageType {
                
                MultiplayerService.shared.addPlayer(with: player.playerID, randomNumber: randomNumber)
                MultiplayerService.shared.setHostPlayer()
//                let allPlayersIsInTheMatch: Bool = match.players.count >= MultiplayerService.shared.allPlayers.count - 1
//
//                if allPlayersIsInTheMatch {
//
//
//                }
                
            }
        }
        
        
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        if (self.currentMatch != match) {
            return
        }
        
        switch state {
        case GKPlayerConnectionState.connected:
            print("Player Conected!")
            playerConnectedDelegate?.didPlayerConnected()
        
        case GKPlayerConnectionState.disconnected:
            print("Player Disconected!")
        default:
            print(state)
        }
    }
}

extension GameCenterService: GKLocalPlayerListener {
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        
        guard GKLocalPlayer.local.isAuthenticated else {return}
        
        GKMatchmaker.shared().match(for: invite) { (match, error) in
            
            if let m = match {
                m.delegate = self
                MultiplayerService.shared.startingGame()
                self.currentMatch = m
                NotificationCenter.default.post(name: .presentGame, object: m)
            }
        }
    }
}

protocol PlayerConnectedDelegate {
    func didPlayerConnected()
}
