//
//  GameViewController.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 21/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView
        
        if let scene = SKScene(fileNamed: "MyScene") {
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)
        }
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
//        skView.showsPhysics = true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
