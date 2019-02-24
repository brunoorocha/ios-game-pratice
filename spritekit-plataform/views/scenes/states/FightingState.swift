//
//  FightingState.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 24/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class FightingState: GKState {
    var scene: SKScene!
    private var timeCount: Double = 0
    
    init(withScene scene: SKScene) {
        self.scene = scene
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        self.scene.view?.isUserInteractionEnabled = true
    }
}
