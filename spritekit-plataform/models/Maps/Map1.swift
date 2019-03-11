//
//  Map1.swift
//  spritekit-plataform
//
//  Created by Thiago Valente on 26/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

class Map1 {
    let scene: SKScene
    
    init(withScene scene: SKScene) {
        self.scene = scene
        self.drawBackground()
        self.drawFloor()
        self.drawPlataform(x: 200, y: 20, width: 200, heigth: 5)
        self.drawPlataform(x: 300, y: 70, width: 200, heigth: 7)
    }
    
    private func drawBackground() {
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
        background.size.height = self.scene.size.height
        background.texture?.filteringMode = .nearest
        background.zPosition = 1
        self.scene.addChild(background)
    }
    
    private func drawFloor(){
        let y = CGFloat(-80.0)
        let area = SKShapeNode(rect: CGRect(x: -self.scene.size.width/2, y: y, width: self.scene.size.width, height: 50))
        area.fillColor = .lightGray
        area.strokeColor = .init(white: 1.0, alpha: 0.0)
        area.physicsBody = SKPhysicsBody(edgeLoopFrom: area.frame)
        area.physicsBody?.categoryBitMask = CategoryMask.ground
        area.physicsBody?.collisionBitMask = CategoryMask.player
        area.physicsBody?.affectedByGravity = false
        area.physicsBody?.restitution = 0
        area.physicsBody?.friction = 0
        area.zPosition = 2
        self.scene.addChild(area)
    }
    
    private func drawPlataform(x: CGFloat, y: CGFloat, width: CGFloat, heigth: CGFloat){
        let area = SKShapeNode(rect: CGRect(x: -1*(x/2), y: y, width: width, height: heigth))
        area.fillColor = .lightGray
        area.strokeColor = .init(white: 1.0, alpha: 0.0)
        area.physicsBody = SKPhysicsBody(edgeLoopFrom: area.frame)
        area.physicsBody?.affectedByGravity = false
        area.physicsBody?.categoryBitMask = CategoryMask.plataform
        area.physicsBody?.friction = 0
        area.physicsBody?.restitution = 0
        area.zPosition = 2
        self.scene.addChild(area)
    }
    
    
}
