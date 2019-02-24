//
//  GesturePad.swift
//  spritekit-demo
//
//  Created by Bruno Rocha on 11/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

fileprivate enum ViewSide {
    case left
    case right
}

class GesturePad: NSObject {
    var view: SKView!
    var delegate: GesturePadDelegate!
    
    private var tapRecognizer: UITapGestureRecognizer!
    private var panRecognizer: UIPanGestureRecognizer!
    private let degressToRadians = Float(CGFloat.pi / 180)
    
    init(forView view: SKView) {
        super.init()
        self.view = view
        setupRecognizers()
//        self.enable()
    }
    
    private func setupRecognizers() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        
        tapRecognizer.delegate = self
        panRecognizer.delegate = self
        
        self.view.addGestureRecognizer(tapRecognizer)
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    func disable() {
        self.view.isUserInteractionEnabled = false
    }
    
    func enable() {
        self.view.isUserInteractionEnabled = true
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let side = viewSide(ofPoint: gesture.location(in: self.view), onView: self.view)
        if (side == .right) {
            delegate.performActionForTap()
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let side = viewSide(ofPoint: gesture.location(in: self.view), onView: self.view)
        if (side == .left) {
            if (gesture.state == .ended || gesture.state == .cancelled) {
                delegate.performActionForAnalogStopMoving()
            }
            
            if (gesture.state == .changed) {
                let translation = gesture.translation(in: view)
                var direction = float2(Float(translation.x), Float(translation.y))
                direction = normalize(direction)
                direction.x = direction.x.isNaN ? 0 : direction.x
                direction.y = direction.y.isNaN ? 0 : direction.y
                
                let directionInDegree = atan2(direction.x, direction.y)
                delegate.performActionForAnalogMoving(inAngle: CGFloat(directionInDegree), withDirectionX: CGFloat(direction.x), AndDirectionY: CGFloat(direction.y))
            }
        }
        
        else if (side == .right) {
            if (gesture.state == .ended || gesture.state == .cancelled) {
                delegate.performActionForSwipe()                
            }
        }
    }
    
    private func viewSide(ofPoint point: CGPoint, onView view: SKView) -> ViewSide {
        let middle = view.frame.width / 2
        if (point.x < middle) {
            return .left
        }        
        return .right
    }
}

extension GesturePad: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if ((gestureRecognizer is UITapGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer) || (gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer)) {
            return true
        }
        
        return false
    }
}

protocol GesturePadDelegate {
    func performActionForAnalogMoving(inAngle angle: CGFloat, withDirectionX dx: CGFloat, AndDirectionY dy: CGFloat)
    func performActionForAnalogStopMoving()
    func performActionForTap()
    func performActionForSwipe()
}
