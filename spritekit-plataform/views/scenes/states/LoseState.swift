//
//  LoseState.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 29/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameplayKit

class LoseState: GKState {
    var scene: MyScene!
    var killerAlias: String?
    init(withScene scene: MyScene) {
        self.scene = scene
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return !(stateClass is LoseState.Type)
    }
    
    override func didEnter(from previousState: GKState?) {
        
        guard let camera = self.scene.camera, let view = self.scene.view else { return }
        
        if (!self.scene.isControlsVisible) {
            self.scene.gesturePad.disable()
        }
        
        let background = SKShapeNode(rectOf: view.frame.size)
        background.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        background.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        background.zPosition = 20
        background.alpha = 0
        
        let titleLabel = SKLabelNode(text: "YOU DIED ☠️")
        titleLabel.fontName = "Rubik Bold"
        titleLabel.color = .white
        titleLabel.fontSize = 32
        titleLabel.position.y = 24
        titleLabel.zPosition = 20
        
        
        
        if let killer = killerAlias {
            let subTitleLabel = SKLabelNode(text: "Killer: \(killer)")
            subTitleLabel.fontName = "Rubik Bold"
            subTitleLabel.color = .white
            subTitleLabel.fontSize = 20
            subTitleLabel.position.y = -15
            subTitleLabel.zPosition = 20
            background.addChild(subTitleLabel)
        }
        
        let marginTop: CGFloat = 56.0
        
        let watchButton = ButtonNode.makeButton(withText: "KEEP WATCHING")
        watchButton.position.y = -marginTop
        watchButton.zPosition = 20
        watchButton.actionBlock = {
            background.run(SKAction.fadeAlpha(to: 0, duration: 0.5)) {
                background.removeFromParent()
            }
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
        
        background.addChild(watchButton)
        background.addChild(returnButton)
        background.addChild(titleLabel)
        camera.addChild(background)
        background.run(SKAction.fadeAlpha(to: 1.0, duration: 0.5)) {
            self.stateMachine?.enter(WatchingState.self)
        }
    }
}
