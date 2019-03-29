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
    
    init(withScene scene: MyScene) {
        self.scene = scene
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let camera = self.scene.camera, let view = self.scene.view else { return }
        
        if (!self.scene.isControlsVisible) {
            self.scene.gesturePad.disable()
        }
        
        let background = SKShapeNode(rectOf: view.frame.size)
        background.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        background.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        background.zPosition = 20
        
        let titleLabel = SKLabelNode(text: "YOU DIED ☠️")
        titleLabel.fontName = "Rubik Bold"
        titleLabel.color = .white
        titleLabel.fontSize = 32
        titleLabel.position.y = 24
        titleLabel.zPosition = 20
        
        let marginTop: CGFloat = 56.0
        
        let returnButton = ButtonNode.makeButton(withText: "RETURN TO MENU")
        returnButton.position.y = -(marginTop + returnButton.size.height + 20)
        returnButton.zPosition = 20
        returnButton.actionBlock = {
            let menuScene = MenuScene(size: view.frame.size)
            menuScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            menuScene.scaleMode = .resizeFill
            let fadeTransition = SKTransition.fade(withDuration: 1.0)
            view.presentScene(menuScene, transition: fadeTransition)
        }
        
        background.addChild(returnButton)
        background.addChild(titleLabel)
        camera.addChild(background)
    }
}
