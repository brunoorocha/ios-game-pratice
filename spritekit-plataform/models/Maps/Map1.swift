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
    
	init(withScene scene: SKScene, andArena arena: Arena) {
        self.scene = scene
        self.drawFloor()
//        self.drawPlataform(x: 200, y: 20, width: 200, heigth: 5)
		let platform = arena.platforms[0]
		drawPlataform(platform)
		let platform2 = arena.platforms[1]
		drawPlataform(platform2)
//        self.drawPlataform(x: 300, y: 70, width: 200, heigth: 7)'
    }
    
    private func drawFloor(){
        let y = CGFloat(-80.0)
        let area = SKShapeNode(rect: CGRect(x: -self.scene.size.width/2, y: y, width: self.scene.size.width, height: 50))
        area.fillColor = .lightGray
        area.physicsBody = SKPhysicsBody(edgeLoopFrom: area.frame)
        area.physicsBody?.categoryBitMask = CategoryMask.ground
        area.physicsBody?.collisionBitMask = CategoryMask.player
        area.physicsBody?.affectedByGravity = false
        area.physicsBody?.restitution = 0
        area.physicsBody?.friction = 0
        self.scene.addChild(area)
    }
    
    private func drawPlataform(x: CGFloat, y: CGFloat, width: CGFloat, heigth: CGFloat){
        let area = SKShapeNode(rect: CGRect(x: -1*(x/2), y: y, width: width, height: heigth))
        area.fillColor = .red
        area.physicsBody = SKPhysicsBody(edgeLoopFrom: area.frame)
        area.physicsBody?.affectedByGravity = false
        area.physicsBody?.categoryBitMask = CategoryMask.plataform
        area.physicsBody?.friction = 0
        area.physicsBody?.restitution = 0
        self.scene.addChild(area)
    }
	
	private func drawPlataform(_ platform: Platform){
		let area = SKSpriteNode(imageNamed: platform.atlas)
		area.size = CGSize(width: 200, height: 7)
		area.position = CGPoint(x: -1*(platform.position.x/2), y: platform.position.y)
		let rect = CGRect(x: -(area.size.width/2), y: -(area.size.height/2), width: area.size.width, height: area.size.height)
		area.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
		area.physicsBody?.affectedByGravity = false
		area.physicsBody?.categoryBitMask = CategoryMask.plataform
		area.physicsBody?.friction = 0
		area.physicsBody?.restitution = 0
		self.scene.addChild(area)
	}
}
