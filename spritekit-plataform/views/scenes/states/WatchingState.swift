//
//  WatchingState.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 31/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class WatchingState: GKState {
    var scene: MyScene!
    
    init(withScene scene: MyScene) {
        self.scene = scene
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is PausedState.Type || stateClass is EndState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let watchingCamera = scene.camera else { return }
        scene.isWatchingMode = true
//        watchingCamera.setScale(1.0)
        watchingCamera.run(
            .group([
                .move(to: CGPoint.zero, duration: 1.0),
                .scale(to: 1.2, duration: 1.0)
            ])
        )
    }
}
