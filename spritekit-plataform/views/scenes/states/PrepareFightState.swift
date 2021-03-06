//
//  PrepareFightState.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 23/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class PrepareFightState: GKState {
    var scene: SKScene!
    private var timeCount: Double = 0
    
    init(withScene scene: SKScene) {
        self.scene = scene
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is FightingState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        self.scene.view?.isUserInteractionEnabled = false
        let getReadyLabel = PreMatchLabel(withText: "GET READY", andWidth: scene.size.width)
        getReadyLabel.node.zPosition = 5
        let fightLabel = PreMatchLabel(withText: "FIGHT", andWidth: scene.size.width)
        fightLabel.node.zPosition = 5
        guard let camera = self.scene.camera else { return }        
        camera.addChild(getReadyLabel.node)
        camera.addChild(fightLabel.node)
        getReadyLabel.show {
            fightLabel.show(afterTime: 0.5) {
                self.stateMachine?.enter(FightingState.self)
            }
        }
    }        
}
