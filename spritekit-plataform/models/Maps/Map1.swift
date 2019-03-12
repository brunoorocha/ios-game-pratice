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
    var parallaxSky: ParallaxBackground!
    var parallaxSea: ParallaxBackground!
    
    init(withScene scene: SKScene) {
        self.scene = scene
        self.drawBackground()
//        self.drawRocks()
        self.drawFloor()
        self.drawPlataform(x: 200, y: 20, width: 200, heigth: 5)
        self.drawPlataform(x: 300, y: 70, width: 200, heigth: 7)
    }
    
    private func drawBackground() {
        let sky = SKSpriteNode(texture: SKTexture(imageNamed: "sky"))
        sky.size.height = self.scene.size.height
        sky.setScale(1.2)
        sky.position = CGPoint(x: 0, y: 50)
        sky.texture?.filteringMode = .nearest
        sky.zPosition = 1
        
        let sea = SKSpriteNode(texture: SKTexture(imageNamed: "sea"))
        sea.size.height = self.scene.size.height
        sea.setScale(1.2)
        sea.position = CGPoint(x: 0, y: 50)
        sea.texture?.filteringMode = .nearest
        sea.zPosition = 2
        
        self.parallaxSky = ParallaxBackground(withCamera: self.scene.camera!, andNode: sky)
        self.parallaxSea = ParallaxBackground(withCamera: self.scene.camera!, andNode: sea)
        self.parallaxSea.layer = 2
        
        self.scene.addChild(sky)
        self.scene.addChild(sea)
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
        area.zPosition = 4
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
        area.zPosition = 4
        self.scene.addChild(area)
    }
    
    func drawRocks() {
        let rocks = SKSpriteNode(texture: SKTexture(imageNamed: "rocks"))
        rocks.setScale(1.2)
        rocks.position = CGPoint(x: 400, y: 0)
        rocks.texture?.filteringMode = .nearest
        rocks.zPosition = 3
        self.scene.addChild(rocks)
    }
    
    func updateParallaxBackground() {
        self.parallaxSky.update()
        self.parallaxSea.update()
    }
}
