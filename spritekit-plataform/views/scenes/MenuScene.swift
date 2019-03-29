//
//  MenuScene.swift
//  spritekit-plataform
//
//  Created by João Paulo de Oliveira Sabino on 01/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit
import GameKit

class MenuScene: SKScene {
    
    var startButton: ButtonNode!
    
    override func didMove(to view: SKView) {
        self.setupBackground()
        self.setupGameName()
        self.setupButtons()
        self.setupUserNickname()
//        if let startBtn = childNode(withName: "StartButton") as? ButtonNode {
//            print("start")
//            self.startButton = startBtn
//            startButton.isUserInteractionEnabled = true
//            startButton.actionBlock = {
//                GameCenterService.shared.presentMatchMaker()
//            }
//
//            startButton.isEnabled = GameCenterService.isAuthenticated
//        }
//
//        if let startSingleBtn = childNode(withName: "StartSingleButton") as? ButtonNode {
//            self.startSingleButton = startSingleBtn
//            startSingleButton.isUserInteractionEnabled = true
//            startSingleButton.actionBlock = {
//                if let gameScene = SKScene(fileNamed: "MyScene") as? MyScene {
//                    gameScene.scaleMode = .resizeFill
//                    view.presentScene(gameScene)
//                }
//            }
//        }
//
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationChanged(_:)), name: .authenticationChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentGame(_:)), name: .presentGame, object: nil)
    }
    
    func setupButtons() {
        let startMargin: CGFloat = 30
        let buttonMargin: CGFloat = 16
        
        self.startButton = ButtonNode.makeButton(withText: "START GAME")
        self.startButton.position.y = -startMargin
        self.startButton.actionBlock = {
            GameCenterService.shared.presentMatchMaker()
        }
        
        let practiceButton = ButtonNode.makeButton(withText: "PRACTICE MODE")
        practiceButton.position.y = -(practiceButton.size.height + buttonMargin + startMargin)
        practiceButton.actionBlock = {
            let practiceScene = MyScene(size: self.size)
            practiceScene.scaleMode = .resizeFill
            let fadeTransition = SKTransition.fade(withDuration: 0.3)
            self.view?.presentScene(practiceScene, transition: fadeTransition)
        }
        
        let settingsButton = ButtonNode.makeButton(withText: "SETTINGS")
        settingsButton.position.y = -(settingsButton.size.height * 2 + buttonMargin * 2 + startMargin)
        settingsButton.actionBlock = {
            let settingsScene = SettingsScene(size: self.size)
            settingsScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            settingsScene.scaleMode = .resizeFill
            let fadeTransition = SKTransition.fade(withDuration: 0.3)
            self.view?.presentScene(settingsScene, transition: fadeTransition)
        }
        
        self.addChild(self.startButton)
        self.addChild(practiceButton)
        self.addChild(settingsButton)
    }
    
    func setupBackground() {
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "menu-bg"), size: (self.view?.frame.size)!)
        self.addChild(background)
    }
    
    func setupGameName() {
        let label = SKLabelNode(text: "SMASH ROYALE")
        label.fontName = "Rubik Black"
        label.fontColor = .white
        label.fontSize = 48
        label.zPosition = 2
        label.position.y = (label.frame.height / 2) + 16
        self.addChild(label)
    }
    
    func setupUserNickname() {
        if (PlayerDefaults.playerAlias == "") { return }
        
        let topLeftCornerX = -((self.view?.frame.width)! / 2)
        let topLeftCornerY = ((self.view?.frame.height)! / 2)
        let userIcon = SKSpriteNode(texture: SKTexture(imageNamed: "user-icon"), size: CGSize(width: 24, height: 24))
        userIcon.position.x = topLeftCornerX + 48
        userIcon.position.y = topLeftCornerY - 40
        userIcon.zPosition = 2
        
        let label = SKLabelNode(text: PlayerDefaults.playerAlias)
        label.fontName = "Rubik Regular"
        label.fontColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        label.fontSize = 12
        label.zPosition = 2
        label.position.x = userIcon.position.x + (label.frame.width / 2) + 20
        label.position.y = userIcon.position.y - (label.frame.height / 2) + 2
        self.addChild(userIcon)
        self.addChild(label)
    }
    
    @objc private func authenticationChanged(_ notification: Notification) {
        if let isConnected = notification.object as? Bool {
            self.startButton.isEnabled = isConnected
            PlayerDefaults.playerAlias = GKLocalPlayer.local.alias
            self.setupUserNickname()
        }
    }

    @objc private func presentGame(_ notification: Notification) {
        guard let match = notification.object as? GKMatch else {
            return
        }

        if let gameScene = SKScene(fileNamed: "MyScene") as? MyScene {
            GameCenterService.shared.playerConnectedDelegate = gameScene
            // Set the scale mode to scale to fit the window
            gameScene.scaleMode = .resizeFill
            //gameScene.currentMatch = match
            self.view?.ignoresSiblingOrder = true
            // Present the scene
            self.view?.presentScene(gameScene, transition: SKTransition.crossFade(withDuration: 1.0))
        }

        GameCenterService.shared.currentMatch = match
    }
}
