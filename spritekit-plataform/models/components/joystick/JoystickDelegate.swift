//
//  JoystickDelegate.swift
//  PlatformerGame
//
//  Created by João Paulo de Oliveira Sabino on 25/02/19.
//  Copyright © 2019 João Paulo de Oliveira Sabino. All rights reserved.
//

import SpriteKit

protocol JoystickDelegate {
    /**
     Callend when start track joystick.
     */
    func joystickDidStartTracking()
    /**
     Callend when joystick is moving.
     - parameter direction: joystick's direction.
     If the direction is in the left side of joystick,
     the direction is negative, in the right side, positive.
     */
    func joystickDidMoved(direction: CGPoint)
    
    /**
     Callend when joystick is tracking, its called at 60fps.
     - parameter direction: joystick's direction.
     If the direction is in the left side of joystick,
     the direction is negative, in the right side, positive.
     */
    func joystickUpdateTracking(direction: CGPoint)
    /**
     Callend after joystick ended tracking(deactivated).
     - parameter direction: joystick's direction.
     If the direction is in the left side of joystick,
     the direction is negative, in the right side, positive.
     */
    func joystickDidEndTracking(direction: CGPoint)
    
    func joystickDidTapButtonA()
    func joystickDidTapButtonB()
    func joystickDidTapDown()
}
