//
//  ButtonNode.swift
//  spritekit-plataform
//
//  Created by João Paulo de Oliveira Sabino on 01/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

class ButtonNode: SKNode {
    
    var actionBlock : (() -> Void)?
    
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

