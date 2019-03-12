//
//  JoystickNode.swift
//  PlatformerGame
//
//  Created by João Paulo de Oliveira Sabino on 16/02/19.
//  Copyright © 2019 João Paulo de Oliveira Sabino. All rights reserved.
//

import SpriteKit

open class JoystickNode: SKNode {
    var substrate : JoystickComponent!
    var stick: JoystickComponent!
    var joystickIsEnabled = false
    private(set) var tracking = false
    private(set) var direction = CGPoint.zero 
    
    var joystickDelegate: JoystickDelegate?
    var disabled: Bool {
        get {
            return !isUserInteractionEnabled
        }
        
        set(isDisabled) {
            isUserInteractionEnabled = !isDisabled
            
            if isDisabled {
                resetStick()
            }
        }
    }
    
    var diameter: CGFloat {
        get {
            return substrate.diameter
        }
        
        set(newDiameter) {
            //stick.diameter += newDiameter - diameter
            substrate.diameter = newDiameter
        }
    }
    
    var radius : CGFloat {
        get {
            return diameter * 0.5
        }
        set(newRadius) {
            diameter = newRadius * 2
        }
    }
    
    init(substrate: JoystickComponent, stick: JoystickComponent) {
        super.init()
        
        self.substrate = substrate
        substrate.zPosition = 0
        self.stick = stick
        stick.zPosition = 1
        
        addChild(substrate)
        addChild(stick)
    
        disabled = false
        
        
    }
        
    convenience init(diameter: CGFloat, colors: (substrate: SKColor?, stick: SKColor?)? = nil, images: (substrate: UIImage?, stick: UIImage?)? = nil) {

        let substrate = JoystickComponent(diameter: diameter, color: colors?.substrate, image: images?.substrate)
        let stick = JoystickComponent(diameter: diameter * 0.5, color: colors?.stick, image: images?.stick)
        self.init(substrate: substrate, stick: stick)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Overrides
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            tracking = true
            joystickIsEnabled = true
            //joystickDelegate?.joystickDidStartTracking()
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            let location = touch.location(in: self)
            
            guard tracking else {
                return
            }
            
            let maxDistance = substrate.radius - (stick.radius / 2)
            let realDistance : CGFloat = hypot(location.x, location.y) //hypot = cauculate the hypotenuse given 2 points
            
            
            let limitedLocation = CGPoint(x: (location.x / realDistance) * maxDistance, y: (location.y / realDistance) * maxDistance)
            
            let needPosition = realDistance <= maxDistance  ? location : limitedLocation
            
            stick.position = needPosition
            
            direction = needPosition
            
            //joystickDelegate?.joystickDidMoved(direction: needPosition)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetStick()
        if let location = touches.first?.location(in: self) {
            joystickDelegate?.joystickDidEndTracking(direction: location)
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetStick()
        if let location = touches.first?.location(in: self) {
            joystickDelegate?.joystickDidEndTracking(direction: location)
        }
        
    }
    
    //MARK: - Private methods
    private func resetStick() {
        isHidden = true
        tracking = false
        let moveToBack = SKAction.move(to: CGPoint.zero, duration: TimeInterval(0.1))
        moveToBack.timingMode = .easeOut
        stick.run(moveToBack)
        direction = CGPoint.zero
    }
}
