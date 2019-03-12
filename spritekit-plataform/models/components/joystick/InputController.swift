//
//  InputArea.swift
//  PlatformerGame
//
//  Created by João Paulo de Oliveira Sabino on 24/02/19.
//  Copyright © 2019 João Paulo de Oliveira Sabino. All rights reserved.
//


import SpriteKit

class InputController: SKSpriteNode {
    var joystick: JoystickNode!
    var joystickDelegate : JoystickDelegate?
    var virtualButtonA: VirtualButtonNode!
    var virtualButtonB: VirtualButtonNode!
    var isDown: Bool = false
    var touchLeft = UITouch()
    
    init(size: CGSize){
        
        super.init(texture: nil, color: SKColor.clear, size: size)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.isUserInteractionEnabled = true
        joystick = JoystickNode(diameter: 120, colors: (substrate: SKColor.gray, stick: SKColor.gray))
        joystick.disabled = true
        let joystickXPosition = -(self.size.width/2) + 120
        let joystickYPosition = -(self.size.height/2) + 100
        joystick.position = CGPoint(x: joystickXPosition, y: joystickYPosition)
        addChild(joystick)
    
        
        let positionButtonA  = CGPoint(x: (self.size.width/2) - 255, y: -(self.size.height/2) + 130)
        virtualButtonA = VirtualButtonNode(name: "A", radius: 40, fillColor: SKColor.gray, inPosition: positionButtonA)
        addChild(virtualButtonA)
        let positionButtonB  = CGPoint(x: (self.size.width/2) - 210, y: -(self.size.height/2) + 160)
        virtualButtonB = VirtualButtonNode(name: "B", radius: 40, fillColor: SKColor.gray, inPosition: positionButtonB)
        addChild(virtualButtonB)
        
        virtualButtonA.actionBlock = {
            self.joystickDelegate?.joystickDidTapButtonA()
        }
        virtualButtonB.actionBlock = {
            if self.isDown {
               self.joystickDelegate?.joystickDidTapDown()
            }else{
                self.joystickDelegate?.joystickDidTapButtonB()
            }
        }
        
        let updateJoystick = CADisplayLink(target: self, selector: #selector(update))
        updateJoystick.preferredFramesPerSecond = 60
        updateJoystick.add(to: .current, forMode: .default)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func update(){
        if joystick.tracking {
            joystickDelegate?.joystickUpdateTracking(direction: joystick.direction)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, (touch.location(in: self).x < 0), (touchLeft != touch) {
            touchLeft = touch
            joystick.disabled = false
            joystick.position = touch.location(in: self)
            joystick.touchesBegan([touch], with: event)
            joystickDelegate?.joystickDidStartTracking()
        }
    
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, (touch.location(in: self).x < 0), (touchLeft == touch) {
            joystick.touchesMoved([touch], with: event)
            joystickDelegate?.joystickDidMoved(direction: joystick.direction)
        
            isDown = joystick.direction.y < -20 ? true : false

        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, (touchLeft == touch) {
            touchLeft = UITouch()
            joystick.disabled = true
            joystick.touchesEnded([touch], with: event)
            joystickDelegate?.joystickDidEndTracking(direction: joystick.direction)
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (_) in
                self.isDown = false
            }
            
        }
        
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, (touchLeft == touch) {
            touchLeft = UITouch()
            joystick.disabled = true
            joystick.touchesCancelled([touch], with: event)
            joystickDelegate?.joystickDidEndTracking(direction: joystick.direction)
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (_) in
                self.isDown = false
            }
        }
        
    }
}


