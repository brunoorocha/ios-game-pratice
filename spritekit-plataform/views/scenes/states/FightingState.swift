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
    var scene: MyScene!
    private var timeCount: Double = 0
    
    init(withScene scene: MyScene) {
        self.scene = scene
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        if (!self.scene.isControlsVisible) {
            self.scene.gesturePad.enable()
        }
        
        self.scene.view?.isUserInteractionEnabled = true
    }
}
