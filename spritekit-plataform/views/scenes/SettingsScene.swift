//
//  SettingsScene.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 28/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

class SettingsScene: SKScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.setupBackground()
        self.setupSettingsOptions()
        self.setupBackButton()
    }
    
    
    func setupBackground() {
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "menu-bg"), size: (self.view?.frame.size)!)
        self.addChild(background)
    }
    
    func setupSettingsOptions() {
        let titleLabel = SKLabelNode(text: "SETTINGS")
        titleLabel.fontName = "Rubik Bold"
        titleLabel.color = .white
        titleLabel.fontSize = 24
        titleLabel.position.y = 48
        titleLabel.zPosition = 2
        
        let controlsSwitch = Switch.makeSwitch(withFirstOption: "HIDE", andSecondOption: "SHOW", andValue: PlayerDefaults.isControlsVisible)
        controlsSwitch.position.x = controlsSwitch.button1.size.width / 2
        controlsSwitch.toggleAction = {
            PlayerDefaults.isControlsVisible = controlsSwitch.value
        }
        
        let controlsLabel = self.makeSettingsLabel(withText: "CONTROLS")
        controlsLabel.position.x = -(controlsSwitch.position.x + (controlsLabel.frame.width / 2))
        controlsLabel.position.y = controlsSwitch.position.y - (controlsLabel.frame.height / 2)
        
        let soundsSwitch = Switch.makeSwitch(withFirstOption: "OFF", andSecondOption: "ON", andValue: PlayerDefaults.isSoundEnabled)
        soundsSwitch.position.x = soundsSwitch.button1.size.width / 2
        soundsSwitch.toggleAction = {
            PlayerDefaults.isSoundEnabled = soundsSwitch.value
        }
        soundsSwitch.position.y = -(controlsSwitch.frame.height + 16)
        let soundsLabel = self.makeSettingsLabel(withText: "SOUNDS")
        soundsLabel.position.x = -(soundsSwitch.position.x + (soundsLabel.frame.width / 2))
        soundsLabel.position.y = soundsSwitch.position.y - 8
        
        self.addChild(titleLabel)
        self.addChild(controlsSwitch)
        self.addChild(controlsLabel)
        self.addChild(soundsSwitch)
        self.addChild(soundsLabel)
    }
    
    private func makeSettingsLabel(withText text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Rubik Regular"
        label.fontColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        label.fontSize = 16
        label.zPosition = 2
        return label
    }
    
    func setupBackButton() {
        let topLeftCornerX = -(self.frame.width / 2)
        let topLeftCornerY = (self.frame.height / 2)
        let backButton = ButtonNode.makeButton(withText: "BACK", andSize: CGSize(width: 80, height: 32))
        backButton.position.x = topLeftCornerX + backButton.size.width
        backButton.position.y = topLeftCornerY - backButton.size.height - 24
        backButton.actionBlock = {
            let menuScene = MenuScene(size: self.size)
            menuScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            menuScene.scaleMode = .resizeFill
            let fadeTransition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(menuScene, transition: fadeTransition)
        }
        self.addChild(backButton)
    }
}
