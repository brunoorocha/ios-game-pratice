//
//  PreMatchLabel.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 24/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

class PreMatchLabel {
    var node: SKSpriteNode!
    var textLabel: SKLabelNode!
    
    init(withText text: String, andWidth width: CGFloat) {
        self.node = SKSpriteNode(texture: SKTexture(imageNamed: "PreGameLabelBackground"))
        self.node.size = CGSize(width: width, height: 80.0)
        self.node.alpha = 0.0
        self.textLabel = SKLabelNode(text: text)
        let labelYPosition = -((node.size.height / 2) - (textLabel.fontSize - 8.0))
        self.textLabel.position = CGPoint(x: 0, y: labelYPosition)
        self.textLabel.fontName = "Helvetica Neue Bold"
        self.textLabel.zPosition = 9
        self.node.zPosition = 8
        self.node.addChild(textLabel)
    }
    
    func show(afterTime time: TimeInterval = 0.0, _ completion: @escaping () -> Void = {}) {
        let startPoint = CGPoint(x: self.node.position.x, y: self.node.position.y - 20.0)
        let endPoint = self.node.position
        self.node.position = startPoint
        self.node.run(
            .sequence([
                .wait(forDuration: time),
                .group([
                    .fadeAlpha(to: 1.0, duration: 0.3),
                    .move(to: endPoint, duration: 0.3)
                ]),
                .wait(forDuration: 1.0),
                .fadeAlpha(to: 0.0, duration: 0.3),
            ]),
            completion: {
                completion()
        })
    }
}
