//
//  ButtonNode.swift
//  spritekit-plataform
//
//  Created by João Paulo de Oliveira Sabino on 01/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

class ButtonNode: SKSpriteNode {
    
    var actionBlock : (() -> Void)?
    static let buttonTexture = SKTexture(imageNamed: "button-bg")
    
    static func makeButton(withText text: String, andSize size: CGSize = CGSize.zero) -> ButtonNode {
        var buttonNode = ButtonNode(texture: ButtonNode.buttonTexture)
        
        if size != CGSize.zero {
            buttonNode = ButtonNode(texture: ButtonNode.buttonTexture, size: size)
        }
        
        buttonNode.isUserInteractionEnabled = true
        buttonNode.addChild(buttonNode.createButtonLabel(withText: text))
        buttonNode.zPosition = 1
        return buttonNode
    }
    
    private func createButtonLabel(withText text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Rubik Bold"
        label.fontColor = .white
        label.fontSize = 12
        label.position.y = -6
        label.zPosition = 2
        return label
    }
    
    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.4
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard isEnabled else {
            return
        }
        
        self.run(SKAction.fadeAlpha(to: 0.2, duration: 0.1))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let block = actionBlock, isEnabled {
            block()
        }
        guard isEnabled else {
            return
        }
        
        self.run(SKAction.fadeAlpha(to: 1, duration: 0.2))
    }
}

