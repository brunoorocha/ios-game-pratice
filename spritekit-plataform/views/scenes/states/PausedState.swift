//
//  PausedState.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 28/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class PausedState: GKState {
    var scene: MyScene!
    
    init(withScene scene: MyScene) {
        self.scene = scene
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is FightingState.Type
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let camera = self.scene.camera, let view = self.scene.view else { return }
        
        if (!self.scene.isControlsVisible) {
            self.scene.gesturePad.disable()
        }
        
        let pausedBackground = SKShapeNode(rectOf: view.frame.size)
        pausedBackground.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        pausedBackground.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        pausedBackground.zPosition = 20
        
        let titleLabel = SKLabelNode(text: "GAME PAUSED")
        titleLabel.fontName = "Rubik Bold"
        titleLabel.color = .white
        titleLabel.fontSize = 32
        titleLabel.position.y = 24
        titleLabel.zPosition = 20
        
        let marginTop: CGFloat = 56.0
        let resumeButton = ButtonNode.makeButton(withText: "RESUME GAME")
        resumeButton.position.y = -marginTop
        resumeButton.zPosition = 20
        resumeButton.actionBlock = {
            pausedBackground.removeFromParent()
            self.stateMachine?.enter(FightingState.self)
        }
        
        let returnButton = ButtonNode.makeButton(withText: "RETURN TO MENU")
        returnButton.position.y = -(marginTop + returnButton.size.height + 20)
        returnButton.zPosition = 20
        returnButton.actionBlock = {
            let menuScene = MenuScene(size: view.frame.size)
            menuScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            menuScene.scaleMode = .resizeFill
            let fadeTransition = SKTransition.fade(withDuration: 1.0)
            view.presentScene(menuScene, transition: fadeTransition)
            GameCenterService.shared.currentMatch?.disconnect()
        }
        
        pausedBackground.addChild(titleLabel)
        pausedBackground.addChild(resumeButton)
        pausedBackground.addChild(returnButton)
        camera.addChild(pausedBackground)
    }
}
