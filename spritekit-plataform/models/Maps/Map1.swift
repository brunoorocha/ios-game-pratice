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
    
	init(withScene scene: SKScene, andArena arena: Arena) {
        self.scene = scene
		//draw platforms
		arena.platforms.forEach { (platform) in
			drawPlataform(platform)
		}
		
		//draw floor
		drawFloor(arena.floor)
		
		//draw background
		arena.background.enumerated().forEach { (index, background) in
			//the index in draw background initiate in 1
			let layer = index + 1
			drawBackground(background, withLayer: layer)
		}
		
		//prop
		drawProp(arena.prop)
    }
	
	private func drawBackground(_ background: String, withLayer layer: Int) {
		let parallaxNode = SKSpriteNode(texture: SKTexture(imageNamed: background))
		parallaxNode.size.height = self.scene.size.height
		parallaxNode.setScale(1.4)
		parallaxNode.position = CGPoint(x: 0, y: 50)
		parallaxNode.texture?.filteringMode = .nearest
		parallaxNode.zPosition = CGFloat(layer)
		
		//preciso saber pq tem o parallax como propriedade
		//mudar init do ParallaxBackground para receber o layer
		let parallax = ParallaxBackground(withCamera: self.scene.camera!, andNode: parallaxNode)
		parallax.layer = layer
		
		switch (layer) {
		case 1:
			parallaxSky = parallax
		case 2:
			parallaxSea = parallax
		default:
			break
		}
		
		self.scene.addChild(parallaxNode)
	}
    
	private func drawFloor(_ floor: String){
        let y = CGFloat(-80.0)
        let ground = SKSpriteNode(texture: SKTexture(imageNamed: floor))
        ground.texture?.filteringMode = .nearest
        ground.position = CGPoint(x: 0, y: y)
        let groundFrame = CGRect(x: -(ground.size.width / 2), y: -((ground.size.height / 2) + 24), width: ground.size.width, height: ground.size.height)
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: groundFrame)
        ground.physicsBody?.categoryBitMask = CategoryMask.ground
        ground.physicsBody?.collisionBitMask = CategoryMask.player
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.restitution = 0
        ground.physicsBody?.friction = 0
        ground.zPosition = 5
		
        self.scene.addChild(ground)
    }
    
    func updateParallaxBackground() {
        self.parallaxSky.update()
        self.parallaxSea.update()
    }
	
	private func drawPlataform(_ platform: Platform){
		let area = SKSpriteNode(imageNamed: platform.atlas)
		area.size = CGSize(width: 190, height: 12)
		area.position = CGPoint(x: -1*(platform.position.x/2), y: platform.position.y)
		area.zPosition = 5
		let rect = CGRect(x: -(area.size.width/2), y: +((area.size.height/2) - 1), width: area.size.width, height: 1)
		area.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
		area.physicsBody?.affectedByGravity = false
		area.physicsBody?.categoryBitMask = CategoryMask.plataform
		area.physicsBody?.friction = 0
		area.physicsBody?.restitution = 0
		
		self.scene.addChild(area)
	}
	
	func drawProp(_ prop: Prop) {
		let propNode = SKSpriteNode(texture: SKTexture(imageNamed: prop.atlas))
		propNode.setScale(prop.scale)
		propNode.position = prop.position
		propNode.texture?.filteringMode = .nearest
		propNode.zPosition = 3
		
		self.scene.addChild(propNode)
	}
}
