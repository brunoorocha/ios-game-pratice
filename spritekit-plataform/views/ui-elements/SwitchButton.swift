//
//  SwitchButton.swift
//  spritekit-plataform
//
//  Created by Bruno Rocha on 27/03/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

class Switch: SKSpriteNode {
    
    var value: Bool = false {
        didSet {
            self.button1.isEnabled = !self.value
            self.button2.isEnabled = self.value
        }
    }
    
    var options: [String]!
    
    var button1: ButtonNode!
    var button2: ButtonNode!
    
    var toggleAction: () -> Void = {}
    
    static func makeSwitch(withFirstOption option1: String, andSecondOption option2: String, andValue value: Bool = false) -> Switch {
        let switchNode = Switch(color: .white, size: CGSize(width: 128, height: 32))
        switchNode.isUserInteractionEnabled = true
        switchNode.options = [option1, option2]
        
        switchNode.button1 = ButtonNode.makeButton(withText: option1, andSize: CGSize(width: 64.0, height: 32.0))
        switchNode.button1.isUserInteractionEnabled = false
        switchNode.button2 = ButtonNode.makeButton(withText: option2, andSize: CGSize(width: 64.0, height: 32.0))
        switchNode.button2.isUserInteractionEnabled = false
        switchNode.button2.position.x = switchNode.button1.frame.width
        
        switchNode.value = value
        switchNode.addChild(switchNode.button1)
        switchNode.addChild(switchNode.button2)
        return switchNode
    }
    
    func switchOptions() {        
        self.value.toggle()
        self.toggleAction()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.switchOptions()
    }
}
